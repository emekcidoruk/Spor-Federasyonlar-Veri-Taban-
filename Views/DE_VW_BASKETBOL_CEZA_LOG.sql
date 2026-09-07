CREATE OR REPLACE VIEW DE_VW_BASKETBOL_CEZA_LOG AS

WITH

/* =========================================================
   1. HER BASKETBOL MACININ BASHAKEMINI BUL
   ========================================================= */
BASHAKEM AS (

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

    WHERE H.FEDERASYON_ID = 2

      AND (
            UPPER(TRIM(FH.HAKEM_GOREVI)) = 'BASHAKEM'
         OR UPPER(TRIM(FH.HAKEM_GOREVI)) = 'BAÞHAKEM'
      )
),


/* =========================================================
   2. BASKETBOL CEZA DETAYLARI
   ========================================================= */
CEZA_DETAY AS (

    SELECT

        /* CEZA LOG */
        CL.CEZA_LOG_ID,
        CL.FEDERASYON_ID,

        /* LIG */
        F.LIG_ID,
        L.LIG_ADI,

        /* FIKSTUR */
        CL.FIKSTUR_ID,
        F.HAFTA,

        /* MAC */
        F.EV_SAHIBI_TAKIM_ID,
        EV.TAKIM_ADI
            AS EV_SAHIBI_TAKIM_ADI,

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

        /* CEZA TURU */
        CL.CEZA_TURU_ID,
        CZ.CEZA_TURU_ADI,

        /* NEDEN */
        CL.ACIKLAMA
            AS CEZA_ACIKLAMASI,

        CASE
            WHEN CL.ACIKLAMA IS NOT NULL
            THEN CL.ACIKLAMA

            ELSE CZ.CEZA_TURU_ADI
        END AS CEZA_NEDENI,

        /* ZAMAN */
        CL.PERIYOT_SET
            AS PERIYOT,

        CL.DAKIKA,

        CL.MAC_TARIHI,

        /* MAC SONUCU */
        F.MAC_SONUCU,

        /* BASHAKEM */
        BH.HAKEM_ID,

        H.HAKEM_ADI_SOYADI,

        FH.HAKEM_GOREVI,

        /* HAKEM KLASMANI */
        H.KLASMAN_ID,
        HK.KLASMAN_TURU,

        CL.ISLEM_TARIHI

    FROM DE_CEZA_LOG CL

    /* SADECE BASKETBOL */
    JOIN DE_FIKSTUR F
        ON F.FIKSTUR_ID = CL.FIKSTUR_ID
       AND F.FEDERASYON_ID = 2

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

    /* BASHAKEM */
    LEFT JOIN BASHAKEM BH
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
           TAKIMIN TEKNIK FAUL SAYISI
           ================================================= */
        SUM(
            CASE
                WHEN UPPER(C.CEZA_TURU_ADI)
                     LIKE '%TEKNIK%'
                THEN 1
                ELSE 0
            END
        ) OVER (
            PARTITION BY
                C.LIG_ID,
                C.TAKIM_ID
        ) AS TAKIM_TEKNIK_FAUL_SAYISI,


        /* =================================================
           TAKIMIN SPORTMENLIK DISI FAUL SAYISI
           ================================================= */
        SUM(
            CASE
                WHEN UPPER(C.CEZA_TURU_ADI)
                     LIKE '%SPORTMENLIK%'
                THEN 1
                ELSE 0
            END
        ) OVER (
            PARTITION BY
                C.LIG_ID,
                C.TAKIM_ID
        ) AS TAKIM_SPORTMENLIK_DISI_SAYISI,


        /* =================================================
           TAKIMIN DISKALIFIYE CEZASI
           ================================================= */
        SUM(
            CASE
                WHEN UPPER(C.CEZA_TURU_ADI)
                     LIKE '%DISKAL%'
                THEN 1
                ELSE 0
            END
        ) OVER (
            PARTITION BY
                C.LIG_ID,
                C.TAKIM_ID
        ) AS TAKIM_DISKALIFIYE_SAYISI,


        /* =================================================
           LIGDEKI TOPLAM CEZA
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
           OYUNCUNUN TOPLAM CEZASI
           ================================================= */
        COUNT(*) OVER (
            PARTITION BY
                C.LIG_ID,
                C.OYUNCU_LISANS_NO
        ) AS OYUNCU_TOPLAM_CEZA,


        /* =================================================
           OYUNCUNUN TEKNIK FAUL SAYISI
           ================================================= */
        SUM(
            CASE
                WHEN UPPER(C.CEZA_TURU_ADI)
                     LIKE '%TEKNIK%'
                THEN 1
                ELSE 0
            END
        ) OVER (
            PARTITION BY
                C.LIG_ID,
                C.OYUNCU_LISANS_NO
        ) AS OYUNCU_TEKNIK_FAUL_SAYISI,


        /* =================================================
           OYUNCUNUN SPORTMENLIK DISI FAUL SAYISI
           ================================================= */
        SUM(
            CASE
                WHEN UPPER(C.CEZA_TURU_ADI)
                     LIKE '%SPORTMENLIK%'
                THEN 1
                ELSE 0
            END
        ) OVER (
            PARTITION BY
                C.LIG_ID,
                C.OYUNCU_LISANS_NO
        ) AS OYUNCU_SPORTMENLIK_DISI_SAYISI,


        /* =================================================
           OYUNCUNUN DISKALIFIYE SAYISI
           ================================================= */
        SUM(
            CASE
                WHEN UPPER(C.CEZA_TURU_ADI)
                     LIKE '%DISKAL%'
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

    PERIYOT,
    DAKIKA,

    MAC_TARIHI,
    MAC_SONUCU,

    HAKEM_ID,
    HAKEM_ADI_SOYADI,
    HAKEM_GOREVI,

    KLASMAN_ID,
    KLASMAN_TURU,

    /* TAKIM ISTATISTIKLERI */
    TAKIM_TOPLAM_CEZA,
    TAKIM_TEKNIK_FAUL_SAYISI,
    TAKIM_SPORTMENLIK_DISI_SAYISI,
    TAKIM_DISKALIFIYE_SAYISI,

    /* LIG ISTATISTIKLERI */
    LIG_TOPLAM_CEZA,
    LIG_CEZA_TURU_UYGULAMA_SAYISI,

    /* OYUNCU ISTATISTIKLERI */
    OYUNCU_TOPLAM_CEZA,
    OYUNCU_TEKNIK_FAUL_SAYISI,
    OYUNCU_SPORTMENLIK_DISI_SAYISI,
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
    CEZA_NEDENI,

    PERIYOT,
    DAKIKA,

    HAKEM_ADI_SOYADI,

    MAC_SONUCU

FROM DE_VW_BASKETBOL_CEZA_LOG

ORDER BY
    LIG_ID,
    HAFTA,
    FIKSTUR_ID,
    PERIYOT,
    DAKIKA;
