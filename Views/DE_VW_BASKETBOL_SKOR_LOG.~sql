CREATE OR REPLACE VIEW DE_VW_BASKETBOL_SKOR_LOG AS

WITH

/* =========================================================
   1. HER BASKETBOL MACININ BASHAKEMINI BUL
   ========================================================= */
BASHAKEM AS (

    SELECT
        FH.FIKSTUR_ID,
        FH.HAKEM_ID,
        FH.HAKEM_GOREVI,

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
   2. BASKETBOL SKOR LOG DETAYLARI
   ========================================================= */
SKOR_DETAY AS (

    SELECT

        /* =================================================
           SKOR LOG
           ================================================= */
        SL.SKOR_LOG_ID,

        SL.FEDERASYON_ID,
        FED.FEDERASYON_ADI,


        /* =================================================
           LIG
           ================================================= */
        F.LIG_ID,
        L.LIG_ADI,


        /* =================================================
           FIKSTUR
           ================================================= */
        SL.FIKSTUR_ID,
        F.HAFTA,


        /* =================================================
           EV SAHIBI
           ================================================= */
        F.EV_SAHIBI_TAKIM_ID,

        EV.TAKIM_ADI
            AS EV_SAHIBI_TAKIM_ADI,


        /* =================================================
           DEPLASMAN
           ================================================= */
        F.DEPLASMAN_TAKIM_ID,

        DEP.TAKIM_ADI
            AS DEPLASMAN_TAKIM_ADI,


        /* =================================================
           SAYIYI YAPAN TAKIM
           ================================================= */
        SL.TAKIM_ID,

        T.TAKIM_ADI
            AS SKOR_YAPAN_TAKIM_ADI,


        CASE

            WHEN SL.TAKIM_ID =
                 F.EV_SAHIBI_TAKIM_ID
            THEN 'EV SAHIBI'

            WHEN SL.TAKIM_ID =
                 F.DEPLASMAN_TAKIM_ID
            THEN 'DEPLASMAN'

            ELSE 'BILINMIYOR'

        END AS TAKIM_TARAFI,


        /* =================================================
           OYUNCU
           ================================================= */
        SL.OYUNCU_LISANS_NO,

        O.OYUNCU_ADI_SOYADI,

        O.OYUNCU_MEVKI,


        /* =================================================
           SKOR OLAYI
           ================================================= */
        SL.SKOR_TURU,

        SL.SKOR_DEGERI,


        /* =================================================
           SKOR KATEGORISI
           ================================================= */
        CASE

            WHEN SL.SKOR_DEGERI = 1
            THEN '1 SAYI'

            WHEN SL.SKOR_DEGERI = 2
            THEN '2 SAYI'

            WHEN SL.SKOR_DEGERI = 3
            THEN '3 SAYI'

            ELSE 'DIGER'

        END AS SKOR_KATEGORISI,


        /* =================================================
           PERIYOT / DAKIKA
           ================================================= */
        SL.PERIYOT_SET
            AS PERIYOT,

        SL.DAKIKA,


        /* =================================================
           MAC
           ================================================= */
        SL.MAC_TARIHI,

        F.MAC_SONUCU,


        /* =================================================
           FINAL SKOR

           92-84
           FINAL_EV_SKOR  = 92
           FINAL_DEP_SKOR = 84
           ================================================= */
        CASE

            WHEN REGEXP_LIKE(
                TRIM(F.MAC_SONUCU),
                '^[0-9]+-[0-9]+$'
            )

            THEN TO_NUMBER(
                REGEXP_SUBSTR(
                    TRIM(F.MAC_SONUCU),
                    '^[0-9]+'
                )
            )

        END AS FINAL_EV_SKOR,


        CASE

            WHEN REGEXP_LIKE(
                TRIM(F.MAC_SONUCU),
                '^[0-9]+-[0-9]+$'
            )

            THEN TO_NUMBER(
                REGEXP_SUBSTR(
                    TRIM(F.MAC_SONUCU),
                    '[0-9]+$'
                )
            )

        END AS FINAL_DEP_SKOR,


        /* =================================================
           MUSABAKA ALANI
           ================================================= */
        F.MUSABAKA_ALANI_ID,

        M.MUSABAKA_ALANI_ADI,

        M.MUSABAKA_ALANI_SEHIR,

        M.MUSABAKA_ALANI_ADRESI,

        M.MUSABAKA_ALANI_KAPASITE,

        M.ZEMIN_TURU,


        /* =================================================
           BASHAKEM
           ================================================= */
        BH.HAKEM_ID,

        H.HAKEM_ADI_SOYADI,

        BH.HAKEM_GOREVI,

        H.KLASMAN_ID,

        HK.KLASMAN_TURU,


        SL.ISLEM_TARIHI

    FROM DE_SKOR_LOG SL


    /* SADECE BASKETBOL */
    JOIN DE_FIKSTUR F
        ON F.FIKSTUR_ID = SL.FIKSTUR_ID
       AND F.FEDERASYON_ID = 2


    JOIN DE_FEDERASYONLAR FED
        ON FED.FEDERASYON_ID =
           F.FEDERASYON_ID


    JOIN DE_LIGLER L
        ON L.LIG_ID =
           F.LIG_ID


    /* SAYIYI YAPAN TAKIM */
    JOIN DE_TAKIMLAR T
        ON T.TAKIM_ID =
           SL.TAKIM_ID


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
           SL.OYUNCU_LISANS_NO


    /* MUSABAKA ALANI */
    JOIN DE_MUSABAKA_ALANI M
        ON M.MUSABAKA_ALANI_ID =
           F.MUSABAKA_ALANI_ID


    /* BASHAKEM */
    LEFT JOIN BASHAKEM BH
        ON BH.FIKSTUR_ID =
           F.FIKSTUR_ID
       AND BH.RN = 1


    LEFT JOIN DE_HAKEMLER H
        ON H.HAKEM_ID =
           BH.HAKEM_ID


    LEFT JOIN DE_HAKEM_KLASMAN HK
        ON HK.KLASMAN_ID =
           H.KLASMAN_ID
),


/* =========================================================
   3. SKOR HESAPLARI
   ========================================================= */
SKOR_HESAP AS (

    SELECT
        S.*,


        /* =================================================
           MACIN KACINCI SKOR OLAYI?
           ================================================= */
        ROW_NUMBER() OVER (

            PARTITION BY S.FIKSTUR_ID

            ORDER BY
                NVL(S.PERIYOT, 0),
                NVL(S.DAKIKA, 0),
                S.SKOR_LOG_ID

        ) AS MAC_SKOR_OLAY_SIRASI,


        /* =================================================
           PERIYOTTA KACINCI SKOR OLAYI?
           ================================================= */
        ROW_NUMBER() OVER (

            PARTITION BY
                S.FIKSTUR_ID,
                S.PERIYOT

            ORDER BY
                NVL(S.DAKIKA, 0),
                S.SKOR_LOG_ID

        ) AS PERIYOT_SKOR_OLAY_SIRASI,


        /* =================================================
           SAYIDAN SONRAKI MAC SKORU - EV SAHIBI
           ================================================= */
        SUM(

            CASE

                WHEN S.TAKIM_ID =
                     S.EV_SAHIBI_TAKIM_ID

                THEN S.SKOR_DEGERI

                ELSE 0

            END

        ) OVER (

            PARTITION BY S.FIKSTUR_ID

            ORDER BY
                NVL(S.PERIYOT, 0),
                NVL(S.DAKIKA, 0),
                S.SKOR_LOG_ID

            ROWS BETWEEN
                UNBOUNDED PRECEDING
                AND CURRENT ROW

        ) AS O_ANKI_EV_SKOR,


        /* =================================================
           SAYIDAN SONRAKI MAC SKORU - DEPLASMAN
           ================================================= */
        SUM(

            CASE

                WHEN S.TAKIM_ID =
                     S.DEPLASMAN_TAKIM_ID

                THEN S.SKOR_DEGERI

                ELSE 0

            END

        ) OVER (

            PARTITION BY S.FIKSTUR_ID

            ORDER BY
                NVL(S.PERIYOT, 0),
                NVL(S.DAKIKA, 0),
                S.SKOR_LOG_ID

            ROWS BETWEEN
                UNBOUNDED PRECEDING
                AND CURRENT ROW

        ) AS O_ANKI_DEP_SKOR,


        /* =================================================
           SADECE BULUNULAN PERIYOTTAKI EV SAHIBI SKORU
           ================================================= */
        SUM(

            CASE

                WHEN S.TAKIM_ID =
                     S.EV_SAHIBI_TAKIM_ID

                THEN S.SKOR_DEGERI

                ELSE 0

            END

        ) OVER (

            PARTITION BY
                S.FIKSTUR_ID,
                S.PERIYOT

            ORDER BY
                NVL(S.DAKIKA, 0),
                S.SKOR_LOG_ID

            ROWS BETWEEN
                UNBOUNDED PRECEDING
                AND CURRENT ROW

        ) AS O_ANKI_PERIYOT_EV_SKOR,


        /* =================================================
           SADECE BULUNULAN PERIYOTTAKI DEPLASMAN SKORU
           ================================================= */
        SUM(

            CASE

                WHEN S.TAKIM_ID =
                     S.DEPLASMAN_TAKIM_ID

                THEN S.SKOR_DEGERI

                ELSE 0

            END

        ) OVER (

            PARTITION BY
                S.FIKSTUR_ID,
                S.PERIYOT

            ORDER BY
                NVL(S.DAKIKA, 0),
                S.SKOR_LOG_ID

            ROWS BETWEEN
                UNBOUNDED PRECEDING
                AND CURRENT ROW

        ) AS O_ANKI_PERIYOT_DEP_SKOR,


        /* =================================================
           OYUNCUNUN BU MACTAKI TOPLAM SAYISI
           ================================================= */
        SUM(S.SKOR_DEGERI) OVER (

            PARTITION BY
                S.FIKSTUR_ID,
                S.OYUNCU_LISANS_NO

        ) AS OYUNCU_MAC_TOPLAM_SAYI,


        /* =================================================
           OYUNCUNUN BU PERIYOTTAKI SAYISI
           ================================================= */
        SUM(S.SKOR_DEGERI) OVER (

            PARTITION BY
                S.FIKSTUR_ID,
                S.PERIYOT,
                S.OYUNCU_LISANS_NO

        ) AS OYUNCU_PERIYOT_TOPLAM_SAYI,


        /* =================================================
           OYUNCUNUN LIGDEKI TOPLAM SAYISI
           ================================================= */
        SUM(S.SKOR_DEGERI) OVER (

            PARTITION BY
                S.LIG_ID,
                S.OYUNCU_LISANS_NO

        ) AS OYUNCU_LIG_TOPLAM_SAYI,


        /* =================================================
           TAKIMIN BU MACTAKI TOPLAM SAYISI
           ================================================= */
        SUM(S.SKOR_DEGERI) OVER (

            PARTITION BY
                S.FIKSTUR_ID,
                S.TAKIM_ID

        ) AS TAKIM_MAC_TOPLAM_SAYI,


        /* =================================================
           TAKIMIN BU PERIYOTTAKI TOPLAM SAYISI
           ================================================= */
        SUM(S.SKOR_DEGERI) OVER (

            PARTITION BY
                S.FIKSTUR_ID,
                S.PERIYOT,
                S.TAKIM_ID

        ) AS TAKIM_PERIYOT_TOPLAM_SAYI,


        /* =================================================
           OYUNCUNUN BU MACTA KAC ADET 1 SAYILIK SKORU VAR?
           ================================================= */
        SUM(
            CASE
                WHEN S.SKOR_DEGERI = 1
                THEN 1
                ELSE 0
            END
        ) OVER (

            PARTITION BY
                S.FIKSTUR_ID,
                S.OYUNCU_LISANS_NO

        ) AS OYUNCU_MAC_1_SAYI_ADEDI,


        /* =================================================
           OYUNCUNUN BU MACTA KAC ADET 2 SAYILIK SKORU VAR?
           ================================================= */
        SUM(
            CASE
                WHEN S.SKOR_DEGERI = 2
                THEN 1
                ELSE 0
            END
        ) OVER (

            PARTITION BY
                S.FIKSTUR_ID,
                S.OYUNCU_LISANS_NO

        ) AS OYUNCU_MAC_2_SAYI_ADEDI,


        /* =================================================
           OYUNCUNUN BU MACTA KAC ADET 3 SAYILIK SKORU VAR?
           ================================================= */
        SUM(
            CASE
                WHEN S.SKOR_DEGERI = 3
                THEN 1
                ELSE 0
            END
        ) OVER (

            PARTITION BY
                S.FIKSTUR_ID,
                S.OYUNCU_LISANS_NO

        ) AS OYUNCU_MAC_3_SAYI_ADEDI

    FROM SKOR_DETAY S
)


/* =========================================================
   4. VIEW SONUCU
   ========================================================= */
SELECT

    /* SKOR LOG */
    SKOR_LOG_ID,


    /* FEDERASYON */
    FEDERASYON_ID,
    FEDERASYON_ADI,


    /* LIG */
    LIG_ID,
    LIG_ADI,


    /* FIKSTUR */
    FIKSTUR_ID,
    HAFTA,


    /* MAC TAKIMLARI */
    EV_SAHIBI_TAKIM_ID,
    EV_SAHIBI_TAKIM_ADI,

    DEPLASMAN_TAKIM_ID,
    DEPLASMAN_TAKIM_ADI,


    /* SAYIYI YAPAN TAKIM */
    TAKIM_ID,
    SKOR_YAPAN_TAKIM_ADI,
    TAKIM_TARAFI,


    /* OYUNCU */
    OYUNCU_LISANS_NO,
    OYUNCU_ADI_SOYADI,
    OYUNCU_MEVKI,


    /* SKOR */
    SKOR_TURU,
    SKOR_DEGERI,
    SKOR_KATEGORISI,


    /* PERIYOT / ZAMAN */
    PERIYOT,
    DAKIKA,


    /* OLAY SIRASI */
    MAC_SKOR_OLAY_SIRASI,
    PERIYOT_SKOR_OLAY_SIRASI,


    /* =====================================================
       SAYIDAN SONRAKI ANLIK MAC SKORU
       ===================================================== */
    O_ANKI_EV_SKOR,
    O_ANKI_DEP_SKOR,

    O_ANKI_EV_SKOR
        || '-'
        || O_ANKI_DEP_SKOR
        AS SAYI_SONRASI_MAC_SKORU,


    /* =====================================================
       BULUNULAN PERIYOTUN O ANKI SKORU
       ===================================================== */
    O_ANKI_PERIYOT_EV_SKOR,
    O_ANKI_PERIYOT_DEP_SKOR,

    O_ANKI_PERIYOT_EV_SKOR
        || '-'
        || O_ANKI_PERIYOT_DEP_SKOR
        AS SAYI_SONRASI_PERIYOT_SKORU,


    /* FINAL SKOR */
    FINAL_EV_SKOR,
    FINAL_DEP_SKOR,

    MAC_SONUCU,


    /* =====================================================
       OYUNCU ISTATISTIKLERI
       ===================================================== */
    OYUNCU_PERIYOT_TOPLAM_SAYI,

    OYUNCU_MAC_TOPLAM_SAYI,

    OYUNCU_LIG_TOPLAM_SAYI,

    OYUNCU_MAC_1_SAYI_ADEDI,

    OYUNCU_MAC_2_SAYI_ADEDI,

    OYUNCU_MAC_3_SAYI_ADEDI,


    /* =====================================================
       TAKIM ISTATISTIKLERI
       ===================================================== */
    TAKIM_PERIYOT_TOPLAM_SAYI,

    TAKIM_MAC_TOPLAM_SAYI,


    /* MAC TARIHI */
    MAC_TARIHI,


    /* MUSABAKA ALANI */
    MUSABAKA_ALANI_ID,
    MUSABAKA_ALANI_ADI,
    MUSABAKA_ALANI_SEHIR,
    MUSABAKA_ALANI_ADRESI,
    MUSABAKA_ALANI_KAPASITE,
    ZEMIN_TURU,


    /* BASHAKEM */
    HAKEM_ID,
    HAKEM_ADI_SOYADI,

    HAKEM_GOREVI,

    KLASMAN_ID,
    KLASMAN_TURU,


    ISLEM_TARIHI

FROM SKOR_HESAP;
/




SELECT
    LIG_ID,
    LIG_ADI,

    OYUNCU_LISANS_NO,
    OYUNCU_ADI_SOYADI,

    MAX(OYUNCU_LIG_TOPLAM_SAYI)
        AS TOPLAM_SAYI

FROM DE_VW_BASKETBOL_SKOR_LOG

GROUP BY
    LIG_ID,
    LIG_ADI,
    OYUNCU_LISANS_NO,
    OYUNCU_ADI_SOYADI

ORDER BY
    LIG_ID,
    TOPLAM_SAYI DESC;
