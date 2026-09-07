CREATE OR REPLACE PROCEDURE DE_FIKSTUR_OLUSTUR (
    P_SEZON_BASLANGIC IN DATE,
    P_LIG_ID          IN NUMBER DEFAULT NULL
)
AS

    TYPE T_TAKIM_LISTESI IS TABLE OF NUMBER;

    V_TAKIMLAR   T_TAKIM_LISTESI;
    V_ROTASYON   T_TAKIM_LISTESI;

    V_GERCEK_TAKIM_SAYISI NUMBER;
    V_ROTASYON_SAYISI     NUMBER;

    V_ILK_DEVRE_HAFTA NUMBER;

    V_TAKIM_1 NUMBER;
    V_TAKIM_2 NUMBER;

    V_EV_TAKIM_ID  NUMBER;
    V_DEP_TAKIM_ID NUMBER;

    V_EV_ALAN_ID  NUMBER;
    V_DEP_ALAN_ID NUMBER;

    V_MAC_TARIHI DATE;

    V_TEMP NUMBER;

    V_MEVCUT NUMBER;

    V_LIG_MAC_SAYISI NUMBER;

    V_TOPLAM_MAC NUMBER := 0;


    /* ======================================================
       TAKIMIN MUSABAKA ALANINI BUL
       ====================================================== */

    FUNCTION ALAN_GETIR (
        P_TAKIM_ID IN NUMBER
    )
    RETURN NUMBER
    AS
        V_ALAN_ID NUMBER;
    BEGIN

        SELECT MIN(MUSABAKA_ALANI_ID)
        INTO V_ALAN_ID
        FROM DE_MUSABAKA_ALANI
        WHERE TAKIM_ID = P_TAKIM_ID;


        IF V_ALAN_ID IS NULL THEN

            RAISE_APPLICATION_ERROR(
                -20010,
                'TAKIM_ID=' ||
                P_TAKIM_ID ||
                ' icin musabaka alani bulunamadi.'
            );

        END IF;


        RETURN V_ALAN_ID;

    END ALAN_GETIR;


BEGIN

    IF P_SEZON_BASLANGIC IS NULL THEN

        RAISE_APPLICATION_ERROR(
            -20001,
            'Sezon baslangic tarihi bos olamaz.'
        );

    END IF;



    /* ======================================================
       TEK LIG GIRILDIYSE VAR MI KONTROL ET
       ====================================================== */

    IF P_LIG_ID IS NOT NULL THEN

        SELECT COUNT(*)
        INTO V_MEVCUT
        FROM DE_LIGLER
        WHERE LIG_ID = P_LIG_ID;


        IF V_MEVCUT = 0 THEN

            RAISE_APPLICATION_ERROR(
                -20002,
                'LIG_ID=' ||
                P_LIG_ID ||
                ' bulunamadi.'
            );

        END IF;

    END IF;



    /* ======================================================
       LIGLER
       ====================================================== */

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


        /* ==================================================
           BU LIGIN FIKSTURU ZATEN VAR MI?
           ================================================== */

        SELECT COUNT(*)
        INTO V_MEVCUT
        FROM DE_FIKSTUR
        WHERE LIG_ID = L.LIG_ID;


        IF V_MEVCUT > 0 THEN

            RAISE_APPLICATION_ERROR(
                -20003,
                'LIG_ID=' ||
                L.LIG_ID ||
                ' icin fikstur zaten mevcut.'
            );

        END IF;



        /* ==================================================
           TAKIMLARI SADECE LIG_ID UZERINDEN AL
           ================================================== */

        SELECT TAKIM_ID
        BULK COLLECT INTO V_TAKIMLAR
        FROM DE_TAKIMLAR
        WHERE LIG_ID = L.LIG_ID
        ORDER BY TAKIM_ID;


        V_GERCEK_TAKIM_SAYISI :=
            V_TAKIMLAR.COUNT;


        IF V_GERCEK_TAKIM_SAYISI < 2 THEN

            CONTINUE;

        END IF;



        /* ==================================================
           TAKIM SAYISI TEK ISE BAY EKLE

           17 takim -> 18 eleman
           0 = BAY
           ================================================== */

        IF MOD(V_GERCEK_TAKIM_SAYISI, 2) = 1 THEN

            V_TAKIMLAR.EXTEND;

            V_TAKIMLAR(
                V_TAKIMLAR.COUNT
            ) := 0;

        END IF;



        V_ROTASYON :=
            V_TAKIMLAR;


        V_ROTASYON_SAYISI :=
            V_ROTASYON.COUNT;



        /* ==================================================
           HAFTA SAYISI

           18 TAKIM -> 17 + 17 = 34
           20 TAKIM -> 19 + 19 = 38
           16 TAKIM -> 15 + 15 = 30
           17 TAKIM -> 17 + 17 = 34
           14 TAKIM -> 13 + 13 = 26
           ================================================== */

        V_ILK_DEVRE_HAFTA :=
            V_ROTASYON_SAYISI - 1;


        V_LIG_MAC_SAYISI := 0;



        /* ==================================================
           ILK DEVRE
           HER HAFTAKI BUTUN MACLAR OLUSTURULUR
           ================================================== */

        FOR V_HAFTA IN 1..V_ILK_DEVRE_HAFTA
        LOOP


            /* ==============================================
               O HAFTAKI BUTUN GECERLI ESLESMELERI OLUSTUR
               ============================================== */

            FOR J IN 1..(V_ROTASYON_SAYISI / 2)
            LOOP

                V_TAKIM_1 :=
                    V_ROTASYON(J);


                V_TAKIM_2 :=
                    V_ROTASYON(
                        V_ROTASYON_SAYISI -
                        J +
                        1
                    );


                /* BAY olmayan bütün eþleþmeleri ekle */

                IF V_TAKIM_1 <> 0
                   AND
                   V_TAKIM_2 <> 0
                THEN


                    /* ======================================
                       EV / DEPLASMAN DAGILIMI
                       ====================================== */

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



                    V_EV_ALAN_ID :=
                        ALAN_GETIR(
                            V_EV_TAKIM_ID
                        );



                    /* ======================================
                       ILK DEVRE TARIHI
                       Ayný haftadaki maçlarý farklý saatlere yay.
                       ====================================== */

                    V_MAC_TARIHI :=

                        TRUNC(P_SEZON_BASLANGIC)

                        +

                        ((V_HAFTA - 1) * 7)

                        +

                        FLOOR((J - 1) / 4)

                        +

                        (
                            13 +
                            MOD(J - 1, 4) * 3
                        ) / 24

                        +

                        ((L.LIG_ID - 1) * 10) / 1440;



                    /* ======================================
                       ILK DEVRE FIKSTUR
                       ====================================== */

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

                        V_EV_ALAN_ID,

                        'OYNANMADI'

                    );


                    V_LIG_MAC_SAYISI :=
                        V_LIG_MAC_SAYISI + 1;


                    V_TOPLAM_MAC :=
                        V_TOPLAM_MAC + 1;



                    /* ======================================
                       IKINCI DEVRE
                       EV VE DEPLASMAN TERS
                       ====================================== */

                    V_DEP_ALAN_ID :=
                        ALAN_GETIR(
                            V_DEP_TAKIM_ID
                        );


                    V_MAC_TARIHI :=

                        TRUNC(P_SEZON_BASLANGIC)

                        +

                        (
                            (
                                V_HAFTA +
                                V_ILK_DEVRE_HAFTA -
                                1
                            ) * 7
                        )

                        +

                        FLOOR((J - 1) / 4)

                        +

                        (
                            13 +
                            MOD(J - 1, 4) * 3
                        ) / 24

                        +

                        ((L.LIG_ID - 1) * 10) / 1440;



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
                        V_ILK_DEVRE_HAFTA,

                        V_DEP_TAKIM_ID,
                        V_EV_TAKIM_ID,

                        V_MAC_TARIHI,

                        V_DEP_ALAN_ID,

                        'OYNANMADI'

                    );


                    V_LIG_MAC_SAYISI :=
                        V_LIG_MAC_SAYISI + 1;


                    V_TOPLAM_MAC :=
                        V_TOPLAM_MAC + 1;


                END IF;

            END LOOP;



            /* ==================================================
               ROUND ROBIN ROTASYONU
               ================================================== */

            V_TEMP :=
                V_ROTASYON(
                    V_ROTASYON_SAYISI
                );


            FOR K IN REVERSE 3..V_ROTASYON_SAYISI
            LOOP

                V_ROTASYON(K) :=
                    V_ROTASYON(K - 1);

            END LOOP;


            V_ROTASYON(2) :=
                V_TEMP;


        END LOOP;



        /* ==================================================
           KONTROL

           N takimli cift devre ligde toplam mac:
           N * (N - 1)
           ================================================== */

        IF V_LIG_MAC_SAYISI <>
           (
               V_GERCEK_TAKIM_SAYISI *
               (V_GERCEK_TAKIM_SAYISI - 1)
           )
        THEN

            RAISE_APPLICATION_ERROR(
                -20020,

                'LIG_ID=' ||
                L.LIG_ID ||

                ' icin beklenen=' ||
                (
                    V_GERCEK_TAKIM_SAYISI *
                    (V_GERCEK_TAKIM_SAYISI - 1)
                ) ||

                ', olusan=' ||
                V_LIG_MAC_SAYISI
            );

        END IF;



        DBMS_OUTPUT.PUT_LINE(
            L.LIG_ADI ||
            ' -> Takim: ' ||
            V_GERCEK_TAKIM_SAYISI ||
            ' -> Mac: ' ||
            V_LIG_MAC_SAYISI ||
            ' -> Hafta: ' ||
            (V_ILK_DEVRE_HAFTA * 2)
        );


    END LOOP;



    DBMS_OUTPUT.PUT_LINE(
        'TOPLAM OLUSTURULAN MAC: ' ||
        V_TOPLAM_MAC
    );


END DE_FIKSTUR_OLUSTUR;
/
