CREATE OR REPLACE VIEW DE_VW_VOLEYBOL_CEZA_LOG AS

WITH

/* =========================================================
   1. HER VOLEYBOL MACININ BIRINCI HAKEMINI BUL
   ========================================================= */
BIRINCI_HAKEM AS (

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

    WHERE H.FEDERASYON_ID = 3

      AND (
            UPPER(TRIM(FH.HAKEM_GOREVI)) = 'BIRINCI HAKEM'
         OR UPPER(TRIM(FH.HAKEM_GOREVI)) = 'BÝRÝNCÝ HAKEM'
      )
),


/* =========================================================
   2. VOLEYBOL CEZA DETAYLARI
   ========================================================= */
CEZA_DETAY AS (

    SELECT

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

        /* CEZA */
        CL.CEZA_TURU_ID,
        CZ.CEZA_TURU_ADI,

        /* CEZA SINIFI */
        CASE

            WHEN UPPER(CZ.CEZA_TURU_ADI)
                 LIKE '%SARI%'
            THEN 'SARI KART'

            WHEN UPPER(CZ.CEZA_TURU_ADI)
                 LIKE '%KIRMIZI%'
            THEN 'KIRMIZI KART'

            WHEN UPPER(CZ.CEZA_TURU_ADI)
                 LIKE '%IHRAC%'
              OR UPPER(CZ.CEZA_TURU_ADI)
                 LIKE '%ÝHRAÇ%'
            THEN 'IHRAC'

            WHEN UPPER(CZ.CEZA_TURU_ADI)
                 LIKE '%DISKAL%'
            THEN 'DISKALIFIYE'

            WHEN UPPER(CZ.CEZA_TURU_ADI)
                 LIKE '%GECIK%'
            THEN 'GECIKTIRME'

            ELSE 'DIGER'

        END AS CEZA_KATEGORISI,

        /* NEDEN */
        CL.ACIKLAMA
            AS CEZA_ACIKLAMASI,

        CASE

            WHEN CL.ACIKLAMA IS NOT NULL
            THEN CL.ACIKLAMA

            ELSE CZ.CEZA_TURU_ADI

        END AS CEZA_NEDENI,

        /* SET / ZAMAN */
        CL.PERIYOT_SET
            AS SET_NO,

        CL.DAKIKA,

        CL.MAC_TARIHI,

        /* MAC SONUCU */
        F.MAC_SONUCU,

        /* BIRINCI HAKEM */
        BH.HAKEM_ID,

        H.HAKEM_ADI_SOYADI,

        FH.HAKEM_GOREVI,

        /* KLASMAN */
        H.KLASMAN_ID,

        HK.KLASMAN_TURU,

        CL.ISLEM_TARIHI

    FROM DE_CEZA_LOG CL


    /* SADECE VOLEYBOL */
    JOIN DE_FIKSTUR F
        ON F.FIKSTUR_ID = CL.FIKSTUR_ID
       AND F.FEDERASYON_ID = 3


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


    /* CEZA TURU */
    JOIN DE_CEZA_TURU CZ
        ON CZ.CEZA_TURU_ID =
           CL.CEZA_TURU_ID


    /* BIRINCI HAKEM */
    LEFT JOIN BIRINCI_HAKEM BH
        ON BH.FIKSTUR_ID =
           CL.FIKSTUR_ID

       AND BH.RN = 1


    LEFT JOIN DE_FIKSTUR_HAKEM FH
        ON FH.FIKSTUR_ID =
           CL.FIKSTUR_ID

       AND FH.HAKEM_ID =
           BH.HAKEM_ID


    LEFT JOIN DE_HAKEMLER H
        ON H.HAKEM_ID =
           BH.HAKEM_ID


    LEFT JOIN DE_HAKEM_KLASMAN HK
        ON HK.KLASMAN_ID =
           H.KLASMAN_ID
),


/* =========================================================
   3. ISTATISTIKLER
   ========================================================= */
ISTATISTIK AS (

    SELECT
        C.*,


        /* =================================================
           TAKIMIN TOPLAM CEZA SAYISI
           ================================================= */
        COUNT(*) OVER (
            PARTITION BY
                C.LIG_ID,
                C.TAKIM_ID
        ) AS TAKIM_TOPLAM_CEZA,


        /* =================================================
           TAKIMIN SARI KART SAYISI
           ================================================= */
        SUM(
            CASE
                WHEN C.CEZA_KATEGORISI = 'SARI KART'
                THEN 1
                ELSE 0
            END
        ) OVER (
            PARTITION BY
                C.LIG_ID,
                C.TAKIM_ID
        ) AS TAKIM_SARI_KART_SAYISI,


        /* =================================================
           TAKIMIN KIRMIZI KART SAYISI
           ================================================= */
        SUM(
            CASE
                WHEN C.CEZA_KATEGORISI = 'KIRMIZI KART'
                THEN 1
                ELSE 0
            END
        ) OVER (
            PARTITION BY
                C.LIG_ID,
                C.TAKIM_ID
        ) AS TAKIM_KIRMIZI_KART_SAYISI,


        /* =================================================
           TAKIMIN IHRAC SAYISI
           ================================================= */
        SUM(
            CASE
                WHEN C.CEZA_KATEGORISI = 'IHRAC'
                THEN 1
                ELSE 0
            END
        ) OVER (
            PARTITION BY
                C.LIG_ID,
                C.TAKIM_ID
        ) AS TAKIM_IHRAC_SAYISI,


        /* =================================================
           TAKIMIN DISKALIFIYE SAYISI
           ================================================= */
        SUM(
            CASE
                WHEN C.CEZA_KATEGORISI = 'DISKALIFIYE'
                THEN 1
                ELSE 0
            END
        ) OVER (
            PARTITION BY
                C.LIG_ID,
                C.TAKIM_ID
        ) AS TAKIM_DISKALIFIYE_SAYISI,


        /* =================================================
           TAKIMIN GECIKTIRME CEZASI
           ================================================= */
        SUM(
            CASE
                WHEN C.CEZA_KATEGORISI = 'GECIKTIRME'
                THEN 1
                ELSE 0
            END
        ) OVER (
            PARTITION BY
                C.LIG_ID,
                C.TAKIM_ID
        ) AS TAKIM_GECIKTIRME_CEZA_SAYISI,


        /* =================================================
           LIGDE UYGULANAN TOPLAM CEZA
           ================================================= */
        COUNT(*) OVER (
            PARTITION BY C.LIG_ID
        ) AS LIG_TOPLAM_CEZA,


        /* =================================================
           CEZA TURUNUN LIGDE KAC KEZ UYGULANDIGI
           ================================================= */
        COUNT(*) OVER (
            PARTITION BY
                C.LIG_ID,
                C.CEZA_TURU_ID
        ) AS LIG_CEZA_TURU_UYGULAMA_SAYISI,


        /* =================================================
           CEZA KATEGORISININ LIGDE KAC KEZ UYGULANDIGI
           ================================================= */
        COUNT(*) OVER (
            PARTITION BY
                C.LIG_ID,
                C.CEZA_KATEGORISI
        ) AS LIG_CEZA_KATEGORI_SAYISI,


        /* =================================================
           OYUNCUNUN TOPLAM CEZA SAYISI
           ================================================= */
        COUNT(*) OVER (
            PARTITION BY
                C.LIG_ID,
                C.OYUNCU_LISANS_NO
        ) AS OYUNCU_TOPLAM_CEZA,


        /* =================================================
           OYUNCUNUN SARI KART SAYISI
           ================================================= */
        SUM(
            CASE
                WHEN C.CEZA_KATEGORISI = 'SARI KART'
                THEN 1
                ELSE 0
            END
        ) OVER (
            PARTITION BY
                C.LIG_ID,
                C.OYUNCU_LISANS_NO
        ) AS OYUNCU_SARI_KART_SAYISI,


        /* =================================================
           OYUNCUNUN KIRMIZI KART SAYISI
           ================================================= */
        SUM(
            CASE
                WHEN C.CEZA_KATEGORISI = 'KIRMIZI KART'
                THEN 1
                ELSE 0
            END
        ) OVER (
            PARTITION BY
                C.LIG_ID,
                C.OYUNCU_LISANS_NO
        ) AS OYUNCU_KIRMIZI_KART_SAYISI,


        /* =================================================
           OYUNCUNUN IHRAC SAYISI
           ================================================= */
        SUM(
            CASE
                WHEN C.CEZA_KATEGORISI = 'IHRAC'
                THEN 1
                ELSE 0
            END
        ) OVER (
            PARTITION BY
                C.LIG_ID,
                C.OYUNCU_LISANS_NO
        ) AS OYUNCU_IHRAC_SAYISI,


        /* =================================================
           OYUNCUNUN DISKALIFIYE SAYISI
           ================================================= */
        SUM(
            CASE
                WHEN C.CEZA_KATEGORISI = 'DISKALIFIYE'
                THEN 1
                ELSE 0
            END
        ) OVER (
            PARTITION BY
                C.LIG_ID,
                C.OYUNCU_LISANS_NO
        ) AS OYUNCU_DISKALIFIYE_SAYISI


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

    /* MAC */
    EV_SAHIBI_TAKIM_ID,
    EV_SAHIBI_TAKIM_ADI,

    DEPLASMAN_TAKIM_ID,
    DEPLASMAN_TAKIM_ADI,

    /* CEZAYI ALAN TAKIM */
    TAKIM_ID,
    TAKIM_ADI,

    /* OYUNCU */
    OYUNCU_LISANS_NO,
    OYUNCU_ADI_SOYADI,
    OYUNCU_MEVKI,

    /* CEZA */
    CEZA_TURU_ID,
    CEZA_TURU_ADI,

    CEZA_KATEGORISI,

    CEZA_NEDENI,
    CEZA_ACIKLAMASI,

    /* SET */
    SET_NO,
    DAKIKA,

    MAC_TARIHI,
    MAC_SONUCU,

    /* HAKEM */
    HAKEM_ID,
    HAKEM_ADI_SOYADI,
    HAKEM_GOREVI,

    KLASMAN_ID,
    KLASMAN_TURU,

    /* =====================================================
       TAKIM ISTATISTIKLERI
       ===================================================== */
    TAKIM_TOPLAM_CEZA,

    TAKIM_SARI_KART_SAYISI,

    TAKIM_KIRMIZI_KART_SAYISI,

    TAKIM_IHRAC_SAYISI,

    TAKIM_DISKALIFIYE_SAYISI,

    TAKIM_GECIKTIRME_CEZA_SAYISI,

    /* =====================================================
       LIG ISTATISTIKLERI
       ===================================================== */
    LIG_TOPLAM_CEZA,

    LIG_CEZA_TURU_UYGULAMA_SAYISI,

    LIG_CEZA_KATEGORI_SAYISI,

    /* =====================================================
       OYUNCU ISTATISTIKLERI
       ===================================================== */
    OYUNCU_TOPLAM_CEZA,

    OYUNCU_SARI_KART_SAYISI,

    OYUNCU_KIRMIZI_KART_SAYISI,

    OYUNCU_IHRAC_SAYISI,

    OYUNCU_DISKALIFIYE_SAYISI,

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
    CEZA_KATEGORISI,

    CEZA_NEDENI,

    SET_NO,

    HAKEM_ADI_SOYADI,
    HAKEM_GOREVI,

    MAC_SONUCU

FROM DE_VW_VOLEYBOL_CEZA_LOG

ORDER BY
    LIG_ID,
    HAFTA,
    FIKSTUR_ID,
    SET_NO;
