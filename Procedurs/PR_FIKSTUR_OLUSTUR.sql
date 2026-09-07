CREATE OR REPLACE PROCEDURE DE_FIKSTUR_OLUSTUR (

    P_SEZON_BASLANGIC IN DATE,
    P_LIG_ID          IN NUMBER DEFAULT NULL

)
AS

    TYPE T_TAKIM_LISTESI IS TABLE OF NUMBER;

    V_TAKIMLAR T_TAKIM_LISTESI;
    V_ROTASYON T_TAKIM_LISTESI;

    V_TAKIM_SAYISI NUMBER;
    V_TUR_SAYISI   NUMBER;
    V_MAC_SAYISI   NUMBER;

    V_TAKIM_1 NUMBER;
    V_TAKIM_2 NUMBER;

    V_EV_TAKIM_ID  NUMBER;
    V_DEP_TAKIM_ID NUMBER;

    V_ALAN_ID NUMBER;

    V_MAC_TARIHI DATE;

    V_TEMP NUMBER;

    V_KONTROL NUMBER;

    V_TOPLAM_MAC NUMBER := 0;


    /* =====================================================
       TAKIMIN MUSABAKA ALANINI BUL
       ===================================================== */

    FUNCTION MUSABAKA_ALANI_GETIR (
        P_TAKIM_ID IN NUMBER
    )
    RETURN NUMBER
    AS

        V_ID NUMBER;

    BEGIN

        SELECT MUSABAKA_ALANI_ID
        INTO V_ID

        FROM (

            SELECT MUSABAKA_ALANI_ID

            FROM DE_MUSABAKA_ALANI

            WHERE TAKIM_ID = P_TAKIM_ID

            ORDER BY MUSABAKA_ALANI_ID

        )

        WHERE ROWNUM = 1;


        RETURN V_ID;


    EXCEPTION

        WHEN NO_DATA_FOUND THEN

            RAISE_APPLICATION_ERROR(
                -20010,
                'TAKIM_ID=' || P_TAKIM_ID ||
                ' icin musabaka alani bulunamadi.'
            );

    END MUSABAKA_ALANI_GETIR;



    /* =====================================================
       ORTAK MUSABAKA ALANI CAKISMA KONTROLU
       ===================================================== */

    FUNCTION UYGUN_TARIH_GETIR (

        P_ALAN_ID IN NUMBER,
        P_TARIH   IN DATE

    )
    RETURN DATE
    AS

        V_TARIH DATE := P_TARIH;

        V_ORTAK_GRUP NUMBER;

        V_CAKISMA NUMBER;

    BEGIN

        /* Alan ortak kullanýlan bir alan mý? */

        SELECT MIN(ORTAK_GRUP_NO)
        INTO V_ORTAK_GRUP

        FROM DE_ORTAK_MUSABAKA_ALANI

        WHERE MUSABAKA_ALANI_ID =
              P_ALAN_ID;


        LOOP

            IF V_ORTAK_GRUP IS NOT NULL THEN

                /* Ayný ortak grubun baþka alaný ayný anda dolu mu? */

                SELECT COUNT(*)
                INTO V_CAKISMA

                FROM DE_FIKSTUR F

                WHERE F.MAC_TARIHI = V_TARIH

                  AND EXISTS (

                        SELECT 1

                        FROM DE_ORTAK_MUSABAKA_ALANI O

                        WHERE O.ORTAK_GRUP_NO =
                              V_ORTAK_GRUP

                          AND O.MUSABAKA_ALANI_ID =
                              F.MUSABAKA_ALANI_ID
                  );

            ELSE

                /* Normal alan */

                SELECT COUNT(*)
                INTO V_CAKISMA

                FROM DE_FIKSTUR

                WHERE MUSABAKA_ALANI_ID =
                      P_ALAN_ID

                  AND MAC_TARIHI =
                      V_TARIH;

            END IF;


            EXIT WHEN V_CAKISMA = 0;


            /* Çakýþýyorsa 2 saat ileri */

            V_TARIH :=
                V_TARIH + (2 / 24);


        END LOOP;


        RETURN V_TARIH;

    END UYGUN_TARIH_GETIR;


BEGIN

    SAVEPOINT SP_FIKSTUR;


    IF P_SEZON_BASLANGIC IS NULL THEN

        RAISE_APPLICATION_ERROR(
            -20001,
            'Sezon baslangic tarihi bos olamaz.'
        );

    END IF;


    /* =====================================================
       LIGLER
       ===================================================== */

    FOR L IN (

        SELECT
            LIG_ID,
            FEDERASYON_ID,
            LIG_ADI

        FROM DE_LIGLER

        WHERE P_LIG_ID IS NULL
           OR LIG_ID = P_LIG_ID

        ORDER BY LIG_ID

    )
    LOOP


        /* Bu lig zaten oluþturuldu mu? */

        SELECT COUNT(*)
        INTO V_KONTROL

        FROM DE_FIKSTUR

        WHERE LIG_ID =
              L.LIG_ID;


        IF V_KONTROL > 0 THEN

            RAISE_APPLICATION_ERROR(
                -20002,
                L.LIG_ADI ||
                ' icin fikstur zaten bulunuyor.'
            );

        END IF;



        /* =================================================
           LIG TAKIMLARI
           ================================================= */

        SELECT TAKIM_ID

        BULK COLLECT INTO V_TAKIMLAR

        FROM DE_TAKIMLAR

        WHERE LIG_ID =
              L.LIG_ID

          AND FEDERASYON_ID =
              L.FEDERASYON_ID

        ORDER BY TAKIM_ID;


        IF V_TAKIMLAR.COUNT < 2 THEN
            CONTINUE;
        END IF;


        /* Tek takým sayýsý -> BAY */

        IF MOD(V_TAKIMLAR.COUNT, 2) = 1 THEN

            V_TAKIMLAR.EXTEND;

            V_TAKIMLAR(
                V_TAKIMLAR.COUNT
            ) := 0;

        END IF;


        V_ROTASYON :=
            V_TAKIMLAR;


        V_TAKIM_SAYISI :=
            V_ROTASYON.COUNT;


        V_TUR_SAYISI :=
            V_TAKIM_SAYISI - 1;


        V_MAC_SAYISI :=
            V_TAKIM_SAYISI / 2;



        /* =================================================
           HAFTALAR
           ================================================= */

        FOR V_HAFTA IN 1..V_TUR_SAYISI LOOP


            FOR J IN 1..V_MAC_SAYISI LOOP


                V_TAKIM_1 :=
                    V_ROTASYON(J);


                V_TAKIM_2 :=
                    V_ROTASYON(
                        V_TAKIM_SAYISI - J + 1
                    );


                /* BAY maç deðil */

                IF V_TAKIM_1 <> 0
                   AND
                   V_TAKIM_2 <> 0
                THEN


                    /* =====================================
                       EV - DEPLASMAN
                       ===================================== */

                    IF MOD(V_HAFTA + J, 2) = 0 THEN

                        V_EV_TAKIM_ID :=
                            V_TAKIM_1;

                        V_DEP_TAKIM_ID :=
                            V_TAKIM_2;

                    ELSE

                        V_EV_TAKIM_ID :=
                            V_TAKIM_2;

                        V_DEP_TAKIM_ID :=
                            V_TAKIM_1;

                    END IF;


                    /* =====================================
                       1. DEVRE
                       ===================================== */

                    V_ALAN_ID :=
                        MUSABAKA_ALANI_GETIR(
                            V_EV_TAKIM_ID
                        );


                    V_MAC_TARIHI :=

                        TRUNC(P_SEZON_BASLANGIC)

                        + ((V_HAFTA - 1) * 7)

                        + FLOOR((J - 1) / 4)

                        + (
                            13 +
                            MOD(J - 1,4) * 3
                          ) / 24

                        + (
                            (L.LIG_ID - 1) * 10
                          ) / 1440;


                    V_MAC_TARIHI :=
                        UYGUN_TARIH_GETIR(
                            V_ALAN_ID,
                            V_MAC_TARIHI
                        );


                    INSERT INTO DE_FIKSTUR (

                        FEDERASYON_ID,
                        LIG_ID,
                        HAFTA,

                        EV_SAHIBI_TAKIM_ID,
                        DEPLASMAN_TAKIM_ID,

                        MAC_TARIHI,

                        MUSABAKA_ALANI_ID,

                        MAC_SONUCU

                    )
                    VALUES (

                        L.FEDERASYON_ID,
                        L.LIG_ID,
                        V_HAFTA,

                        V_EV_TAKIM_ID,
                        V_DEP_TAKIM_ID,

                        V_MAC_TARIHI,

                        V_ALAN_ID,

                        'OYNANMADI'

                    );


                    V_TOPLAM_MAC :=
                        V_TOPLAM_MAC + 1;



                    /* =====================================
                       2. DEVRE - ROVANS
                       ===================================== */

                    V_TEMP :=
                        V_EV_TAKIM_ID;


                    V_EV_TAKIM_ID :=
                        V_DEP_TAKIM_ID;


                    V_DEP_TAKIM_ID :=
                        V_TEMP;


                    V_ALAN_ID :=
                        MUSABAKA_ALANI_GETIR(
                            V_EV_TAKIM_ID
                        );


                    V_MAC_TARIHI :=

                        TRUNC(P_SEZON_BASLANGIC)

                        + (
                            (
                                V_HAFTA +
                                V_TUR_SAYISI -
                                1
                            ) * 7
                          )

                        + FLOOR((J - 1) / 4)

                        + (
                            13 +
                            MOD(J - 1,4) * 3
                          ) / 24

                        + (
                            (L.LIG_ID - 1) * 10
                          ) / 1440;


                    V_MAC_TARIHI :=
                        UYGUN_TARIH_GETIR(
                            V_ALAN_ID,
                            V_MAC_TARIHI
                        );


                    INSERT INTO DE_FIKSTUR (

                        FEDERASYON_ID,
                        LIG_ID,
                        HAFTA,

                        EV_SAHIBI_TAKIM_ID,
                        DEPLASMAN_TAKIM_ID,

                        MAC_TARIHI,

                        MUSABAKA_ALANI_ID,

                        MAC_SONUCU

                    )
                    VALUES (

                        L.FEDERASYON_ID,
                        L.LIG_ID,

                        V_HAFTA +
                        V_TUR_SAYISI,

                        V_EV_TAKIM_ID,
                        V_DEP_TAKIM_ID,

                        V_MAC_TARIHI,

                        V_ALAN_ID,

                        'OYNANMADI'

                    );


                    V_TOPLAM_MAC :=
                        V_TOPLAM_MAC + 1;


                END IF;

            END LOOP;



            /* =============================================
               ROUND ROBIN ROTASYONU
               ============================================= */

            V_TEMP :=
                V_ROTASYON(
                    V_TAKIM_SAYISI
                );


            IF V_TAKIM_SAYISI > 2 THEN

                FOR K IN REVERSE
                    3..V_TAKIM_SAYISI
                LOOP

                    V_ROTASYON(K) :=
                        V_ROTASYON(K - 1);

                END LOOP;

            END IF;


            V_ROTASYON(2) :=
                V_TEMP;


        END LOOP;


        DBMS_OUTPUT.PUT_LINE(
            L.LIG_ADI ||
            ' fiksturu tamamlandi.'
        );


    END LOOP;


    DBMS_OUTPUT.PUT_LINE(
        'Toplam olusturulan mac: ' ||
        V_TOPLAM_MAC
    );


EXCEPTION

    WHEN OTHERS THEN

        ROLLBACK TO SP_FIKSTUR;

        RAISE;

END DE_FIKSTUR_OLUSTUR;
/
