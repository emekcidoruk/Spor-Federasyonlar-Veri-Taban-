CREATE OR REPLACE PROCEDURE DE_CEZA_LOG_YENIDEN_OLUSTUR (
    P_FIKSTUR_ID IN NUMBER
)
AS

    V_FEDERASYON_ID NUMBER;

    V_EV_TAKIM_ID NUMBER;
    V_DEP_TAKIM_ID NUMBER;

    V_TAKIM_ID NUMBER;

    V_MAC_TARIHI DATE;

    V_OYUNCU NUMBER;

    V_CEZA_TURU_ID NUMBER;

    V_CEZA_SAYISI NUMBER;

BEGIN

    SELECT
        FEDERASYON_ID,
        EV_SAHIBI_TAKIM_ID,
        DEPLASMAN_TAKIM_ID,
        MAC_TARIHI

    INTO
        V_FEDERASYON_ID,
        V_EV_TAKIM_ID,
        V_DEP_TAKIM_ID,
        V_MAC_TARIHI

    FROM DE_FIKSTUR

    WHERE FIKSTUR_ID =
          P_FIKSTUR_ID;


    DELETE FROM DE_CEZA_LOG
    WHERE FIKSTUR_ID =
          P_FIKSTUR_ID;


    /* Kesinlikle en az 1 ceza */
    V_CEZA_SAYISI :=
        TRUNC(DBMS_RANDOM.VALUE(1,3));


    FOR I IN 1..V_CEZA_SAYISI LOOP


        IF DBMS_RANDOM.VALUE(0,1) < 0.5 THEN
            V_TAKIM_ID := V_EV_TAKIM_ID;
        ELSE
            V_TAKIM_ID := V_DEP_TAKIM_ID;
        END IF;


        SELECT OYUNCU_LISANS_NO
        INTO V_OYUNCU

        FROM (
            SELECT OYUNCU_LISANS_NO
            FROM DE_OYUNCULAR
            WHERE TAKIM_ID =
                  V_TAKIM_ID
            ORDER BY DBMS_RANDOM.VALUE
        )

        WHERE ROWNUM = 1;



        SELECT CEZA_TURU_ID
        INTO V_CEZA_TURU_ID

        FROM (
            SELECT CEZA_TURU_ID

            FROM DE_CEZA_TURU

            WHERE FEDERASYON_ID =
                  V_FEDERASYON_ID

            ORDER BY DBMS_RANDOM.VALUE
        )

        WHERE ROWNUM = 1;



        INSERT INTO DE_CEZA_LOG (
            FEDERASYON_ID,
            FIKSTUR_ID,
            MAC_TARIHI,
            OYUNCU_LISANS_NO,
            TAKIM_ID,
            CEZA_TURU_ID,
            DAKIKA,
            PERIYOT_SET,
            ACIKLAMA
        )
        VALUES (
            V_FEDERASYON_ID,
            P_FIKSTUR_ID,
            V_MAC_TARIHI,
            V_OYUNCU,
            V_TAKIM_ID,
            V_CEZA_TURU_ID,

            CASE
                WHEN V_FEDERASYON_ID = 1
                    THEN TRUNC(DBMS_RANDOM.VALUE(1,91))

                WHEN V_FEDERASYON_ID = 2
                    THEN TRUNC(DBMS_RANDOM.VALUE(1,11))

                ELSE NULL
            END,

            CASE
                WHEN V_FEDERASYON_ID = 2
                    THEN TRUNC(DBMS_RANDOM.VALUE(1,5))

                WHEN V_FEDERASYON_ID = 3
                    THEN TRUNC(DBMS_RANDOM.VALUE(1,6))

                ELSE NULL
            END,

            'Otomatik olusturulan ceza kaydi'
        );

    END LOOP;


EXCEPTION

    WHEN NO_DATA_FOUND THEN

        RAISE_APPLICATION_ERROR(
            -21100,
            'Ceza log icin oyuncu veya ceza turu bulunamadi.'
        );

END DE_CEZA_LOG_YENIDEN_OLUSTUR;
/
