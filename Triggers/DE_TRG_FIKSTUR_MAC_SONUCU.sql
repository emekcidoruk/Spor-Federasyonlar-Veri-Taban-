CREATE OR REPLACE TRIGGER TRG_FIKSTUR_MAC_SONUCU

FOR UPDATE OF MAC_SONUCU
ON DE_FIKSTUR

COMPOUND TRIGGER


    TYPE T_ID_LIST IS TABLE OF NUMBER
        INDEX BY PLS_INTEGER;

    V_FIKSTURLER T_ID_LIST;

    V_SAYAC PLS_INTEGER := 0;



    /* =====================================================
       SONUC FORMAT KONTROLU
       ===================================================== */

    BEFORE EACH ROW IS

        V_EV  NUMBER;
        V_DEP NUMBER;

    BEGIN

        IF UPPER(TRIM(:NEW.MAC_SONUCU))
           <> 'OYNANMADI'
        THEN


            IF NOT REGEXP_LIKE(
                TRIM(:NEW.MAC_SONUCU),
                '^[0-9]+-[0-9]+$'
            )
            THEN

                RAISE_APPLICATION_ERROR(
                    -21200,
                    'Mac sonucu formati gecersiz.'
                );

            END IF;


            V_EV :=
                TO_NUMBER(
                    REGEXP_SUBSTR(
                        :NEW.MAC_SONUCU,
                        '^[0-9]+'
                    )
                );


            V_DEP :=
                TO_NUMBER(
                    REGEXP_SUBSTR(
                        :NEW.MAC_SONUCU,
                        '[0-9]+$'
                    )
                );


            /* Basketbol beraberlik olmaz */

            IF :NEW.FEDERASYON_ID = 2
               AND V_EV = V_DEP
            THEN

                RAISE_APPLICATION_ERROR(
                    -21201,
                    'Basketbol beraberlikle bitemez.'
                );

            END IF;


            /* Voleybol */

            IF :NEW.FEDERASYON_ID = 3 THEN

                IF NOT (
                    (V_EV = 3 AND V_DEP BETWEEN 0 AND 2)

                    OR

                    (V_DEP = 3 AND V_EV BETWEEN 0 AND 2)
                )
                THEN

                    RAISE_APPLICATION_ERROR(
                        -21202,
                        'Voleybol sonucu gecersiz.'
                    );

                END IF;

            END IF;

        END IF;

    END BEFORE EACH ROW;



    /* =====================================================
       DEGISEN FIKSTURU HAFIZAYA AL
       ===================================================== */

    AFTER EACH ROW IS
    BEGIN

        IF NVL(:OLD.MAC_SONUCU, '#')
           <>
           NVL(:NEW.MAC_SONUCU, '#')
        THEN

            V_SAYAC :=
                V_SAYAC + 1;

            V_FIKSTURLER(
                V_SAYAC
            ) :=
                :NEW.FIKSTUR_ID;

        END IF;

    END AFTER EACH ROW;



    /* =====================================================
       UPDATE BITTIKTEN SONRA PROCEDURE CALISIR
       ===================================================== */

    AFTER STATEMENT IS
    BEGIN

        IF V_SAYAC > 0 THEN

            FOR I IN 1..V_SAYAC LOOP

                DE_MAC_SONUCU_SONRASI(
                    V_FIKSTURLER(I)
                );

            END LOOP;

        END IF;

    END AFTER STATEMENT;


END TRG_FIKSTUR_MAC_SONUCU;
/
