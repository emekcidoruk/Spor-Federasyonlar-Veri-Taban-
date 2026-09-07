CREATE OR REPLACE PROCEDURE DE_MAC_SONUCLARINI_OLUSTUR (

    P_HAFTA  IN NUMBER,
    P_LIG_ID IN NUMBER DEFAULT NULL

)
AS

    V_EV NUMBER;
    V_DEP NUMBER;

    V_KAYBEDEN_SET NUMBER;

    V_HAKEM_SAYISI NUMBER;
    V_GEREKEN_HAKEM NUMBER;

    V_MAC_SAYISI NUMBER := 0;


BEGIN

    SAVEPOINT SP_MAC_SONUCU;


    IF P_HAFTA IS NULL
       OR P_HAFTA <= 0
    THEN

        RAISE_APPLICATION_ERROR(
            -20400,
            'Gecerli hafta giriniz.'
        );

    END IF;


    FOR F IN (

        SELECT
            FI.FIKSTUR_ID,
            FI.FEDERASYON_ID,
            FI.LIG_ID,

            FI.EV_SAHIBI_TAKIM_ID,
            EV.TAKIM_ADI AS EV_SAHIBI_TAKIM_ADI,

            FI.DEPLASMAN_TAKIM_ID,
            DEP.TAKIM_ADI AS DEPLASMAN_TAKIM_ADI

        FROM DE_FIKSTUR FI

        JOIN DE_TAKIMLAR EV
            ON EV.TAKIM_ID =
               FI.EV_SAHIBI_TAKIM_ID

        JOIN DE_TAKIMLAR DEP
            ON DEP.TAKIM_ID =
               FI.DEPLASMAN_TAKIM_ID

        WHERE FI.HAFTA =
              P_HAFTA

          AND (
                P_LIG_ID IS NULL
                OR FI.LIG_ID = P_LIG_ID
              )

          AND UPPER(TRIM(FI.MAC_SONUCU))
              = 'OYNANMADI'

        ORDER BY
            FI.LIG_ID,
            FI.FIKSTUR_ID

    )
    LOOP


        /* =================================================
           HAKEM KADROSU TAM MI?
           ================================================= */

        IF F.FEDERASYON_ID = 1 THEN

            V_GEREKEN_HAKEM := 6;

        ELSIF F.FEDERASYON_ID = 2 THEN

            V_GEREKEN_HAKEM := 3;

        ELSIF F.FEDERASYON_ID = 3 THEN

            V_GEREKEN_HAKEM := 4;

        ELSE

            RAISE_APPLICATION_ERROR(
                -20401,
                'Bilinmeyen federasyon.'
            );

        END IF;


        SELECT COUNT(*)
        INTO V_HAKEM_SAYISI
        FROM DE_FIKSTUR_HAKEM
        WHERE FIKSTUR_ID =
              F.FIKSTUR_ID;


        IF V_HAKEM_SAYISI <>
           V_GEREKEN_HAKEM
        THEN

            RAISE_APPLICATION_ERROR(
                -20402,

                'FIKSTUR_ID=' ||
                F.FIKSTUR_ID ||
                ' hakem kadrosu eksik. Beklenen=' ||
                V_GEREKEN_HAKEM ||
                ', mevcut=' ||
                V_HAKEM_SAYISI
            );

        END IF;


        /* =================================================
           FUTBOL
           ================================================= */

        IF F.FEDERASYON_ID = 1 THEN


            /* =============================================
               AMEDSPOR EV SAHIBIYSE
               AMEDSPOR KESIN KAYBEDER

               Örnek:
               0-2
               1-3
               2-4
               4-5
               ============================================= */

            IF UPPER(F.EV_SAHIBI_TAKIM_ADI)
               LIKE '%AMED%'
            THEN

                /* Amedspor 0-4 arasýnda gol atar */
                V_EV :=
                    TRUNC(
                        DBMS_RANDOM.VALUE(0,5)
                    );

                /* Rakibi mutlaka daha fazla atar */
                V_DEP :=
                    TRUNC(
                        DBMS_RANDOM.VALUE(
                            V_EV + 1,
                            6
                        )
                    );


            /* =============================================
               AMEDSPOR DEPLASMANDAYSA
               AMEDSPOR KESIN KAYBEDER
               ============================================= */

            ELSIF UPPER(F.DEPLASMAN_TAKIM_ADI)
                  LIKE '%AMED%'
            THEN

                /* Amedspor 0-4 arasýnda gol atar */
                V_DEP :=
                    TRUNC(
                        DBMS_RANDOM.VALUE(0,5)
                    );

                /* Ev sahibi mutlaka daha fazla atar */
                V_EV :=
                    TRUNC(
                        DBMS_RANDOM.VALUE(
                            V_DEP + 1,
                            6
                        )
                    );


            /* =============================================
               DIGER FUTBOL MACLARI NORMAL RANDOM
               ============================================= */

            ELSE

                V_EV :=
                    TRUNC(
                        DBMS_RANDOM.VALUE(0,6)
                    );

                V_DEP :=
                    TRUNC(
                        DBMS_RANDOM.VALUE(0,6)
                    );

            END IF;


        /* =================================================
           BASKETBOL
           ================================================= */

        ELSIF F.FEDERASYON_ID = 2 THEN

            V_EV :=
                TRUNC(
                    DBMS_RANDOM.VALUE(65,121)
                );

            V_DEP :=
                TRUNC(
                    DBMS_RANDOM.VALUE(65,121)
                );


            /* Basketbolda beraberlik olmasýn */
            IF V_EV = V_DEP THEN

                IF V_EV < 120 THEN
                    V_EV := V_EV + 1;
                ELSE
                    V_DEP := V_DEP - 1;
                END IF;

            END IF;


        /* =================================================
           VOLEYBOL
           ================================================= */

        ELSE

            V_KAYBEDEN_SET :=
                TRUNC(
                    DBMS_RANDOM.VALUE(0,3)
                );


            IF DBMS_RANDOM.VALUE(0,1)
               < 0.5
            THEN

                V_EV := 3;
                V_DEP := V_KAYBEDEN_SET;

            ELSE

                V_EV := V_KAYBEDEN_SET;
                V_DEP := 3;

            END IF;

        END IF;


        /* =================================================
           MAC SONUCUNU GUNCELLE

           BURADA MAC SONUCU TRIGGER'I DEVREYE GIRECEK
           ================================================= */

        UPDATE DE_FIKSTUR

        SET
            MAC_SONUCU =
                V_EV ||
                '-' ||
                V_DEP,

            ISLEM_TARIHI =
                SYSDATE

        WHERE FIKSTUR_ID =
              F.FIKSTUR_ID;


        V_MAC_SAYISI :=
            V_MAC_SAYISI + 1;


        /* Test için ekrana sonucu da basalým */

        DBMS_OUTPUT.PUT_LINE(

            F.EV_SAHIBI_TAKIM_ADI ||
            ' ' ||
            V_EV ||
            '-' ||
            V_DEP ||
            ' ' ||
            F.DEPLASMAN_TAKIM_ADI

        );


    END LOOP;


    DBMS_OUTPUT.PUT_LINE(
        P_HAFTA ||
        '. hafta sonuclandirildi.'
    );


    DBMS_OUTPUT.PUT_LINE(
        'Mac sayisi: ' ||
        V_MAC_SAYISI
    );


EXCEPTION

    WHEN OTHERS THEN

        ROLLBACK TO SP_MAC_SONUCU;

        RAISE;

END DE_MAC_SONUCLARINI_OLUSTUR;
