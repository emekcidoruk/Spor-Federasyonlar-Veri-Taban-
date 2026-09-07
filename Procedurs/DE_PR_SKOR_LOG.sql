CREATE OR REPLACE PROCEDURE DE_SKOR_LOG_YENIDEN_OLUSTUR (
    P_FIKSTUR_ID IN NUMBER
)
AS

    V_FEDERASYON_ID NUMBER;
    V_EV_TAKIM_ID   NUMBER;
    V_DEP_TAKIM_ID  NUMBER;

    V_MAC_TARIHI    DATE;
    V_MAC_SONUCU    VARCHAR2(50);

    V_EV_SKOR       NUMBER;
    V_DEP_SKOR      NUMBER;

    V_OYUNCU        NUMBER;
    V_KALAN         NUMBER;
    V_DEGER         NUMBER;

    V_TOPLAM_SET    NUMBER;
    V_EV_SET_KALAN  NUMBER;
    V_DEP_SET_KALAN NUMBER;

    V_KAZANAN       NUMBER;
    V_KAYBEDEN      NUMBER;

    V_KAZ_PUAN      NUMBER;
    V_KAY_PUAN      NUMBER;


    /* Rastgele oyuncu */
    FUNCTION OYUNCU_GETIR (
        P_TAKIM_ID IN NUMBER
    )
    RETURN NUMBER
    AS
        V_ID NUMBER;
    BEGIN

        SELECT OYUNCU_LISANS_NO
        INTO V_ID
        FROM (
            SELECT OYUNCU_LISANS_NO
            FROM DE_OYUNCULAR
            WHERE TAKIM_ID = P_TAKIM_ID
            ORDER BY DBMS_RANDOM.VALUE
        )
        WHERE ROWNUM = 1;

        RETURN V_ID;

    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            RAISE_APPLICATION_ERROR(
                -21001,
                'TAKIM_ID=' || P_TAKIM_ID ||
                ' icin oyuncu bulunamadi.'
            );
    END;


BEGIN

    SELECT
        FEDERASYON_ID,
        EV_SAHIBI_TAKIM_ID,
        DEPLASMAN_TAKIM_ID,
        MAC_TARIHI,
        MAC_SONUCU
    INTO
        V_FEDERASYON_ID,
        V_EV_TAKIM_ID,
        V_DEP_TAKIM_ID,
        V_MAC_TARIHI,
        V_MAC_SONUCU
    FROM DE_FIKSTUR
    WHERE FIKSTUR_ID = P_FIKSTUR_ID;


    IF UPPER(TRIM(V_MAC_SONUCU)) = 'OYNANMADI' THEN
        RETURN;
    END IF;


    V_EV_SKOR :=
        TO_NUMBER(
            REGEXP_SUBSTR(
                V_MAC_SONUCU,
                '^[0-9]+'
            )
        );

    V_DEP_SKOR :=
        TO_NUMBER(
            REGEXP_SUBSTR(
                V_MAC_SONUCU,
                '[0-9]+$'
            )
        );


    DELETE FROM DE_SKOR_LOG
    WHERE FIKSTUR_ID = P_FIKSTUR_ID;


    /* =====================================================
       FUTBOL
       ===================================================== */

    IF V_FEDERASYON_ID = 1 THEN


        IF V_EV_SKOR > 0 THEN

            FOR I IN 1..V_EV_SKOR LOOP

                V_OYUNCU :=
                    OYUNCU_GETIR(V_EV_TAKIM_ID);

                INSERT INTO DE_SKOR_LOG (
                    FEDERASYON_ID,
                    FIKSTUR_ID,
                    MAC_TARIHI,
                    OYUNCU_LISANS_NO,
                    TAKIM_ID,
                    SKOR_TURU,
                    SKOR_DEGERI,
                    DAKIKA,
                    PERIYOT_SET
                )
                VALUES (
                    1,
                    P_FIKSTUR_ID,
                    V_MAC_TARIHI,
                    V_OYUNCU,
                    V_EV_TAKIM_ID,
                    'GOL',
                    1,
                    TRUNC(DBMS_RANDOM.VALUE(1, 91)),
                    NULL
                );

            END LOOP;

        END IF;


        IF V_DEP_SKOR > 0 THEN

            FOR I IN 1..V_DEP_SKOR LOOP

                V_OYUNCU :=
                    OYUNCU_GETIR(V_DEP_TAKIM_ID);

                INSERT INTO DE_SKOR_LOG (
                    FEDERASYON_ID,
                    FIKSTUR_ID,
                    MAC_TARIHI,
                    OYUNCU_LISANS_NO,
                    TAKIM_ID,
                    SKOR_TURU,
                    SKOR_DEGERI,
                    DAKIKA,
                    PERIYOT_SET
                )
                VALUES (
                    1,
                    P_FIKSTUR_ID,
                    V_MAC_TARIHI,
                    V_OYUNCU,
                    V_DEP_TAKIM_ID,
                    'GOL',
                    1,
                    TRUNC(DBMS_RANDOM.VALUE(1, 91)),
                    NULL
                );

            END LOOP;

        END IF;



    /* =====================================================
       BASKETBOL
       ===================================================== */

    ELSIF V_FEDERASYON_ID = 2 THEN


        /* EV SAHIBI */

        V_KALAN := V_EV_SKOR;

        WHILE V_KALAN > 0 LOOP

            IF V_KALAN = 1 THEN
                V_DEGER := 1;

            ELSIF V_KALAN = 2 THEN
                V_DEGER := 2;

            ELSE
                V_DEGER :=
                    TRUNC(DBMS_RANDOM.VALUE(1,4));

                IF V_DEGER > V_KALAN THEN
                    V_DEGER := 1;
                END IF;
            END IF;


            V_OYUNCU :=
                OYUNCU_GETIR(V_EV_TAKIM_ID);


            INSERT INTO DE_SKOR_LOG (
                FEDERASYON_ID,
                FIKSTUR_ID,
                MAC_TARIHI,
                OYUNCU_LISANS_NO,
                TAKIM_ID,
                SKOR_TURU,
                SKOR_DEGERI,
                DAKIKA,
                PERIYOT_SET
            )
            VALUES (
                2,
                P_FIKSTUR_ID,
                V_MAC_TARIHI,
                V_OYUNCU,
                V_EV_TAKIM_ID,

                CASE V_DEGER
                    WHEN 3 THEN '3 SAYI'
                    WHEN 2 THEN '2 SAYI'
                    ELSE 'SERBEST ATIS'
                END,

                V_DEGER,

                TRUNC(DBMS_RANDOM.VALUE(1,11)),
                TRUNC(DBMS_RANDOM.VALUE(1,5))
            );


            V_KALAN :=
                V_KALAN - V_DEGER;

        END LOOP;



        /* DEPLASMAN */

        V_KALAN := V_DEP_SKOR;

        WHILE V_KALAN > 0 LOOP

            IF V_KALAN = 1 THEN
                V_DEGER := 1;

            ELSIF V_KALAN = 2 THEN
                V_DEGER := 2;

            ELSE
                V_DEGER :=
                    TRUNC(DBMS_RANDOM.VALUE(1,4));

                IF V_DEGER > V_KALAN THEN
                    V_DEGER := 1;
                END IF;
            END IF;


            V_OYUNCU :=
                OYUNCU_GETIR(V_DEP_TAKIM_ID);


            INSERT INTO DE_SKOR_LOG (
                FEDERASYON_ID,
                FIKSTUR_ID,
                MAC_TARIHI,
                OYUNCU_LISANS_NO,
                TAKIM_ID,
                SKOR_TURU,
                SKOR_DEGERI,
                DAKIKA,
                PERIYOT_SET
            )
            VALUES (
                2,
                P_FIKSTUR_ID,
                V_MAC_TARIHI,
                V_OYUNCU,
                V_DEP_TAKIM_ID,

                CASE V_DEGER
                    WHEN 3 THEN '3 SAYI'
                    WHEN 2 THEN '2 SAYI'
                    ELSE 'SERBEST ATIS'
                END,

                V_DEGER,

                TRUNC(DBMS_RANDOM.VALUE(1,11)),
                TRUNC(DBMS_RANDOM.VALUE(1,5))
            );


            V_KALAN :=
                V_KALAN - V_DEGER;

        END LOOP;



    /* =====================================================
       VOLEYBOL
       ===================================================== */

    ELSIF V_FEDERASYON_ID = 3 THEN

        V_TOPLAM_SET :=
            V_EV_SKOR + V_DEP_SKOR;

        V_EV_SET_KALAN :=
            V_EV_SKOR;

        V_DEP_SET_KALAN :=
            V_DEP_SKOR;


        FOR S IN 1..V_TOPLAM_SET LOOP


            /* Final sete doðru sonucu garanti et */

            IF V_EV_SET_KALAN > 0
               AND
               (
                   V_DEP_SET_KALAN = 0
                   OR
                   DBMS_RANDOM.VALUE(0,1) < 0.5
               )
            THEN

                V_KAZANAN :=
                    V_EV_TAKIM_ID;

                V_KAYBEDEN :=
                    V_DEP_TAKIM_ID;

                V_EV_SET_KALAN :=
                    V_EV_SET_KALAN - 1;

            ELSE

                V_KAZANAN :=
                    V_DEP_TAKIM_ID;

                V_KAYBEDEN :=
                    V_EV_TAKIM_ID;

                V_DEP_SET_KALAN :=
                    V_DEP_SET_KALAN - 1;

            END IF;


            IF S = 5 THEN

                V_KAZ_PUAN := 15;

                V_KAY_PUAN :=
                    TRUNC(DBMS_RANDOM.VALUE(7,15));

            ELSE

                V_KAZ_PUAN := 25;

                V_KAY_PUAN :=
                    TRUNC(DBMS_RANDOM.VALUE(15,25));

            END IF;


            V_OYUNCU :=
                OYUNCU_GETIR(V_KAZANAN);


            INSERT INTO DE_SKOR_LOG (
                FEDERASYON_ID,
                FIKSTUR_ID,
                MAC_TARIHI,
                OYUNCU_LISANS_NO,
                TAKIM_ID,
                SKOR_TURU,
                SKOR_DEGERI,
                DAKIKA,
                PERIYOT_SET
            )
            VALUES (
                3,
                P_FIKSTUR_ID,
                V_MAC_TARIHI,
                V_OYUNCU,
                V_KAZANAN,
                'SET_PUANI',
                V_KAZ_PUAN,
                NULL,
                S
            );


            V_OYUNCU :=
                OYUNCU_GETIR(V_KAYBEDEN);


            INSERT INTO DE_SKOR_LOG (
                FEDERASYON_ID,
                FIKSTUR_ID,
                MAC_TARIHI,
                OYUNCU_LISANS_NO,
                TAKIM_ID,
                SKOR_TURU,
                SKOR_DEGERI,
                DAKIKA,
                PERIYOT_SET
            )
            VALUES (
                3,
                P_FIKSTUR_ID,
                V_MAC_TARIHI,
                V_OYUNCU,
                V_KAYBEDEN,
                'SET_PUANI',
                V_KAY_PUAN,
                NULL,
                S
            );

        END LOOP;

    END IF;

END DE_SKOR_LOG_YENIDEN_OLUSTUR;
/
