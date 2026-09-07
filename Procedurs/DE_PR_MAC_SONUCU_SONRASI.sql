CREATE OR REPLACE PROCEDURE DE_MAC_SONUCU_SONRASI (
    P_FIKSTUR_ID IN NUMBER
)
AS

    V_MAC_SONUCU VARCHAR2(50);
    V_LIG_ID     NUMBER;

BEGIN

    SELECT
        MAC_SONUCU,
        LIG_ID

    INTO
        V_MAC_SONUCU,
        V_LIG_ID

    FROM DE_FIKSTUR

    WHERE FIKSTUR_ID =
          P_FIKSTUR_ID;



    /* =====================================================
       MAÇ TEKRAR OYNANMADI YAPILDIYSA
       ===================================================== */

    IF UPPER(TRIM(V_MAC_SONUCU))
       = 'OYNANMADI'
    THEN

        DELETE FROM DE_SKOR_LOG
        WHERE FIKSTUR_ID =
              P_FIKSTUR_ID;


        DELETE FROM DE_CEZA_LOG
        WHERE FIKSTUR_ID =
              P_FIKSTUR_ID;


        /* Atanmýþ hakemleri tekrar ATANDI yap */

        UPDATE DE_HAKEMLER H

        SET H.HAKEM_ATANMA =
            'ATANDI'

        WHERE H.HAKEM_ID IN (

            SELECT FH.HAKEM_ID

            FROM DE_FIKSTUR_HAKEM FH

            WHERE FH.FIKSTUR_ID =
                  P_FIKSTUR_ID
        );


        DE_PUAN_DURUMU_HESAPLA(
            V_LIG_ID
        );


        RETURN;

    END IF;



    /* =====================================================
       1. SKOR LOG
       ===================================================== */

    DE_SKOR_LOG_YENIDEN_OLUSTUR(
        P_FIKSTUR_ID
    );



    /* =====================================================
       2. CEZA LOG
       ===================================================== */

    DE_CEZA_LOG_YENIDEN_OLUSTUR(
        P_FIKSTUR_ID
    );



    /* =====================================================
       3. EN KRITIK KISIM

       MAC BITTI ->
       O MACIN BUTUN HAKEMLERI ATANMADI

       GELECEK MAC KONTROLU YOK.
       ===================================================== */

    UPDATE DE_HAKEMLER H

    SET H.HAKEM_ATANMA =
        'ATANMADI'

    WHERE H.HAKEM_ID IN (

        SELECT FH.HAKEM_ID

        FROM DE_FIKSTUR_HAKEM FH

        WHERE FH.FIKSTUR_ID =
              P_FIKSTUR_ID
    );



    /* =====================================================
       4. PUAN DURUMU
       ===================================================== */

    DE_PUAN_DURUMU_HESAPLA(
        V_LIG_ID
    );


END DE_MAC_SONUCU_SONRASI;
/
