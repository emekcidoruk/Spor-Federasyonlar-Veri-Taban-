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
            FIKSTUR_ID,
            FEDERASYON_ID,
            LIG_ID

        FROM DE_FIKSTUR

        WHERE HAFTA =
              P_HAFTA

          AND (
                P_LIG_ID IS NULL
                OR LIG_ID = P_LIG_ID
              )

          AND UPPER(TRIM(MAC_SONUCU))
              = 'OYNANMADI'

        ORDER BY
            LIG_ID,
            FIKSTUR_ID

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

            V_EV :=
                TRUNC(
                    DBMS_RANDOM.VALUE(0,6)
                );

            V_DEP :=
                TRUNC(
                    DBMS_RANDOM.VALUE(0,6)
                );



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


            IF V_EV = V_DEP THEN
                V_EV := V_EV + 1;
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

                V_DEP :=
                    V_KAYBEDEN_SET;

            ELSE

                V_EV :=
                    V_KAYBEDEN_SET;

                V_DEP := 3;

            END IF;

        END IF;



        /* =================================================
           UPDATE

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
/
