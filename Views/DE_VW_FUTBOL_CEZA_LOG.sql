CREATE OR REPLACE VIEW DE_VW_FUTBOL_CEZA_LOG AS

WITH

/* =========================================================
   1. HER FUTBOL MACININ ORTA HAKEMINI BUL
   ========================================================= */
ORTA_HAKEM AS (

    SELECT
        FH.FIKSTUR_ID,
        FH.HAKEM_ID,

        ROW_NUMBER() OVER (
            PARTITION BY FH.FIKSTUR_ID
            ORDER BY FH.FIKSTUR_HAKEM_ID
        ) AS RN

    FROM DE_FIKSTUR_HAKEM FH

    JOIN DE_HAKEMLER H
        ON H.HAKEM_ID = FH.HAKEM_ID

    WHERE H.FEDERASYON_ID = 1

      AND UPPER(TRIM(FH.HAKEM_GOREVI))
          = 'ORTA HAKEM'
),


/* =========================================================
   2. FUTBOL CEZA KAYITLARININ DETAYLARI
   ========================================================= */
CEZA_DETAY AS (

    SELECT

        /* CEZA */
        CL.CEZA_LOG_ID,

        CL.FEDERASYON_ID,

        /* LIG */
        F.LIG_ID,
        L.LIG_ADI,

        /* FIKSTUR */
        CL.FIKSTUR_ID,
        F.HAFTA,

        /* EV SAHIBI */
        F.EV_SAHIBI_TAKIM_ID,
        EV.TAKIM_ADI
            AS EV_SAHIBI_TAKIM_ADI,

        /* DEPLASMAN */
        F.DEPLASMAN_TAKIM_ID,
        DEP.TAKIM_ADI
            AS DEPLASMAN_TAKIM_ADI,

        /* CEZAYI ALAN TAKIM */
        CL.TAKIM_ID,

        CT.TAKIM_ADI,

        /* OYUNCU */
        CL.OYUNCU_LISANS_NO,

        O.OYUNCU_ADI_SOYADI,

        O.OYUNCU_MEVKI,

        /* CEZA TÜRÜ */
        CL.CEZA_TURU_ID,

        CZ.CEZA_TURU_ADI,

        /* CEZA NEDENI / ACIKLAMA */
        CL.ACIKLAMA
            AS CEZA_ACIKLAMASI,

        CASE

            WHEN CL.ACIKLAMA IS NOT NULL
            THEN CL.ACIKLAMA

            ELSE CZ.CEZA_TURU_ADI

        END AS CEZA_NEDENI,

        /* OLAY ZAMANI */
        CL.DAKIKA,

        CL.MAC_TARIHI,

        /* MAC SONUCU */
        F.MAC_SONUCU,

        /* HAKEM */
        OH.HAKEM_ID,

        H.HAKEM_ADI_SOYADI,

        FH.HAKEM_GOREVI,

        /* KLASMAN */
        H.KLASMAN_ID,

        HK.KLASMAN_TURU,

        /* LOG ISLEM TARIHI */
        CL.ISLEM_TARIHI

    FROM DE_CEZA_LOG CL


    /* =============================================
       SADECE FUTBOL
       ============================================= */
    JOIN DE_FIKSTUR F
        ON F.FIKSTUR_ID = CL.FIKSTUR_ID
       AND F.FEDERASYON_ID = 1


    /* LIG */
    JOIN DE_LIGLER L
        ON L.LIG_ID = F.LIG_ID


    /* CEZAYI ALAN TAKIM */
    JOIN DE_TAKIMLAR CT
        ON CT.TAKIM_ID = CL.TAKIM_ID


    /* EV SAHIBI */
    JOIN DE_TAKIMLAR EV
        ON EV.TAKIM_ID =
           F.EV_SAHIBI_TAKIM_ID


    /* DEPLASMAN */
    JOIN DE_TAKIMLAR DEP
        ON DEP.TAKIM_ID =
           F.DEPLASMAN_TAKIM_ID


    /* OYUNCU */
    LEFT JOIN DE_OYUNCULAR O
        ON O.OYUNCU_LISANS_NO =
           CL.OYUNCU_LISANS_NO


    /* CEZA TÜRÜ */
    JOIN DE_CEZA_TURU CZ
        ON CZ.CEZA_TURU_ID =
           CL.CEZA_TURU_ID


    /* ORTA HAKEM */
    LEFT JOIN ORTA_HAKEM OH
        ON OH.FIKSTUR_ID =
           CL.FIKSTUR_ID
       AND OH.RN = 1


    LEFT JOIN DE_FIKSTUR_HAKEM FH
        ON FH.FIKSTUR_ID =
           CL.FIKSTUR_ID
       AND FH.HAKEM_ID =
           OH.HAKEM_ID


    LEFT JOIN DE_HAKEMLER H
        ON H.HAKEM_ID =
           OH.HAKEM_ID


    LEFT JOIN DE_HAKEM_KLASMAN HK
        ON HK.KLASMAN_ID =
           H.KLASMAN_ID

),


/* =========================================================
   3. ISTATISTIKLERI HESAPLA
   ========================================================= */
ISTATISTIK AS (

    SELECT
        C.*,


        /* =================================================
           TAKIMIN TOPLAM CEZASI
           ================================================= */
        COUNT(*) OVER (
            PARTITION BY
                C.LIG_ID,
                C.TAKIM_ID
        ) AS TAKIM_TOPLAM_CEZA,


        /* =================================================
           TAKIMIN KIRMIZI KART SAYISI
           ================================================= */
        SUM(

            CASE

                WHEN UPPER(C.CEZA_TURU_ADI)
                     LIKE '%KIRMIZI%'

                THEN 1

                ELSE 0

            END

        ) OVER (

            PARTITION BY
                C.LIG_ID,
                C.TAKIM_ID

        ) AS TAKIM_KIRMIZI_KART_SAYISI,


        /* =================================================
           LIGDE UYGULANAN TOPLAM CEZA
           ================================================= */
        COUNT(*) OVER (
            PARTITION BY C.LIG_ID
        ) AS LIG_TOPLAM_CEZA,


        /* =================================================
           BU CEZA TURU LIGDE KAC KEZ UYGULANDI?
           ================================================= */
        COUNT(*) OVER (

            PARTITION BY
                C.LIG_ID,
                C.CEZA_TURU_ID

        ) AS LIG_CEZA_TURU_UYGULAMA_SAYISI,


        /* =================================================
           OYUNCUNUN TOPLAM CEZA SAYISI
           ================================================= */
        COUNT(*) OVER (

            PARTITION BY
                C.LIG_ID,
                C.OYUNCU_LISANS_NO

        ) AS OYUNCU_TOPLAM_CEZA,


        /* =================================================
           OYUNCUNUN KIRMIZI KART SAYISI
           ================================================= */
        SUM(

            CASE

                WHEN UPPER(C.CEZA_TURU_ADI)
                     LIKE '%KIRMIZI%'

                THEN 1

                ELSE 0

            END

        ) OVER (

            PARTITION BY
                C.LIG_ID,
                C.OYUNCU_LISANS_NO

        ) AS OYUNCU_KIRMIZI_KART_SAYISI

    FROM CEZA_DETAY C
)


/* =========================================================
   VIEW SONUCU
   ========================================================= */
SELECT

    CEZA_LOG_ID,

    FEDERASYON_ID,

    LIG_ID,
    LIG_ADI,

    FIKSTUR_ID,
    HAFTA,

    EV_SAHIBI_TAKIM_ID,
    EV_SAHIBI_TAKIM_ADI,

    DEPLASMAN_TAKIM_ID,
    DEPLASMAN_TAKIM_ADI,

    TAKIM_ID,
    TAKIM_ADI,

    OYUNCU_LISANS_NO,
    OYUNCU_ADI_SOYADI,
    OYUNCU_MEVKI,

    CEZA_TURU_ID,
    CEZA_TURU_ADI,

    CEZA_NEDENI,
    CEZA_ACIKLAMASI,

    DAKIKA,

    MAC_TARIHI,
    MAC_SONUCU,

    HAKEM_ID,
    HAKEM_ADI_SOYADI,

    HAKEM_GOREVI,

    KLASMAN_ID,
    KLASMAN_TURU,

    /* ÝSTATÝSTÝKLER */
    TAKIM_TOPLAM_CEZA,
    TAKIM_KIRMIZI_KART_SAYISI,

    LIG_TOPLAM_CEZA,
    LIG_CEZA_TURU_UYGULAMA_SAYISI,

    OYUNCU_TOPLAM_CEZA,
    OYUNCU_KIRMIZI_KART_SAYISI,

    ISLEM_TARIHI

FROM ISTATISTIK;
/





SELECT
    LIG_ADI,
    HAFTA,
    EV_SAHIBI_TAKIM_ADI,
    DEPLASMAN_TAKIM_ADI,

    TAKIM_ADI,

    OYUNCU_ADI_SOYADI,

    CEZA_TURU_ADI,
    CEZA_NEDENI,

    DAKIKA,

    HAKEM_ADI_SOYADI,
    HAKEM_GOREVI,

    MAC_SONUCU

FROM DE_VW_FUTBOL_CEZA_LOG

ORDER BY
    LIG_ID,
    HAFTA,
    FIKSTUR_ID,
    DAKIKA;
