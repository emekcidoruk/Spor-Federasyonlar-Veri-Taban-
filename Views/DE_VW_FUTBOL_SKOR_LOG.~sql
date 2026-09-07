CREATE OR REPLACE VIEW DE_VW_FUTBOL_SKOR_LOG AS

WITH

/* =========================================================
   1. HER MACIN ORTA HAKEMINI BUL
   ========================================================= */
ORTA_HAKEM AS (

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

    WHERE H.FEDERASYON_ID = 1

      AND UPPER(TRIM(FH.HAKEM_GOREVI))
          = 'ORTA HAKEM'
),


/* =========================================================
   2. FUTBOL SKOR LOG DETAYLARI
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
           GOLU ATAN TAKIM
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

        SL.DAKIKA,


        /* =================================================
           MAC
           ================================================= */
        SL.MAC_TARIHI,

        F.MAC_SONUCU,


        /* =================================================
           FINAL SKORU AYIR

           3-1 ->
           FINAL_EV_GOL  = 3
           FINAL_DEP_GOL = 1
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

        END AS FINAL_EV_GOL,


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

        END AS FINAL_DEP_GOL,


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
           ORTA HAKEM
           ================================================= */
        OH.HAKEM_ID,

        H.HAKEM_ADI_SOYADI,

        OH.HAKEM_GOREVI,

        H.KLASMAN_ID,

        HK.KLASMAN_TURU,


        /* =================================================
           ISLEM TARIHI
           ================================================= */
        SL.ISLEM_TARIHI

    FROM DE_SKOR_LOG SL


    /* SADECE FUTBOL FIKSTURLERI */
    JOIN DE_FIKSTUR F
        ON F.FIKSTUR_ID = SL.FIKSTUR_ID
       AND F.FEDERASYON_ID = 1


    JOIN DE_FEDERASYONLAR FED
        ON FED.FEDERASYON_ID =
           F.FEDERASYON_ID


    JOIN DE_LIGLER L
        ON L.LIG_ID =
           F.LIG_ID


    /* SKORU YAPAN TAKIM */
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


    /* ORTA HAKEM */
    LEFT JOIN ORTA_HAKEM OH
        ON OH.FIKSTUR_ID =
           F.FIKSTUR_ID
       AND OH.RN = 1


    LEFT JOIN DE_HAKEMLER H
        ON H.HAKEM_ID =
           OH.HAKEM_ID


    LEFT JOIN DE_HAKEM_KLASMAN HK
        ON HK.KLASMAN_ID =
           H.KLASMAN_ID


    /* SADECE FUTBOL GOL OLAYLARI */
    WHERE UPPER(TRIM(SL.SKOR_TURU))
          LIKE '%GOL%'
),


/* =========================================================
   3. GOL SIRASI VE O ANKI SKORU HESAPLA
   ========================================================= */
SKOR_HESAP AS (

    SELECT
        S.*,


        /* =================================================
           MAC ICINDE KACINCI GOL?
           ================================================= */
        ROW_NUMBER() OVER (

            PARTITION BY S.FIKSTUR_ID

            ORDER BY
                NVL(S.DAKIKA, 0),
                S.SKOR_LOG_ID

        ) AS MAC_GOL_SIRASI,


        /* =================================================
           EV SAHIBININ O ANA KADAR ATTIGI GOL
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
                NVL(S.DAKIKA, 0),
                S.SKOR_LOG_ID

            ROWS BETWEEN
                UNBOUNDED PRECEDING
                AND CURRENT ROW

        ) AS O_ANKI_EV_SKOR,


        /* =================================================
           DEPLASMANIN O ANA KADAR ATTIGI GOL
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
                NVL(S.DAKIKA, 0),
                S.SKOR_LOG_ID

            ROWS BETWEEN
                UNBOUNDED PRECEDING
                AND CURRENT ROW

        ) AS O_ANKI_DEP_SKOR,


        /* =================================================
           OYUNCUNUN BU MACTAKI GOL SAYISI
           ================================================= */
        SUM(S.SKOR_DEGERI) OVER (

            PARTITION BY
                S.FIKSTUR_ID,
                S.OYUNCU_LISANS_NO

        ) AS OYUNCU_MAC_GOL_SAYISI,


        /* =================================================
           OYUNCUNUN LIGDEKI TOPLAM GOL SAYISI
           ================================================= */
        SUM(S.SKOR_DEGERI) OVER (

            PARTITION BY
                S.LIG_ID,
                S.OYUNCU_LISANS_NO

        ) AS OYUNCU_LIG_GOL_SAYISI,


        /* =================================================
           TAKIMIN BU MACTAKI TOPLAM GOLU
           ================================================= */
        SUM(S.SKOR_DEGERI) OVER (

            PARTITION BY
                S.FIKSTUR_ID,
                S.TAKIM_ID

        ) AS TAKIM_MAC_GOL_SAYISI

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


    /* MAC */
    EV_SAHIBI_TAKIM_ID,
    EV_SAHIBI_TAKIM_ADI,

    DEPLASMAN_TAKIM_ID,
    DEPLASMAN_TAKIM_ADI,


    /* GOLU ATAN TAKIM */
    TAKIM_ID,
    SKOR_YAPAN_TAKIM_ADI,

    TAKIM_TARAFI,


    /* OYUNCU */
    OYUNCU_LISANS_NO,
    OYUNCU_ADI_SOYADI,
    OYUNCU_MEVKI,


    /* GOL */
    SKOR_TURU,
    SKOR_DEGERI,

    DAKIKA,

    MAC_GOL_SIRASI,


    /* =====================================================
       GOL SONRASI ANLIK SKOR
       ===================================================== */
    O_ANKI_EV_SKOR,
    O_ANKI_DEP_SKOR,

    O_ANKI_EV_SKOR
        || '-'
        || O_ANKI_DEP_SKOR
        AS GOL_SONRASI_SKOR,


    /* FINAL SKOR */
    FINAL_EV_GOL,
    FINAL_DEP_GOL,

    MAC_SONUCU,


    /* OYUNCU / TAKIM ISTATISTIKLERI */
    OYUNCU_MAC_GOL_SAYISI,
    OYUNCU_LIG_GOL_SAYISI,

    TAKIM_MAC_GOL_SAYISI,


    /* MAC TARIHI */
    MAC_TARIHI,


    /* SAHA */
    MUSABAKA_ALANI_ID,
    MUSABAKA_ALANI_ADI,
    MUSABAKA_ALANI_SEHIR,
    MUSABAKA_ALANI_ADRESI,
    MUSABAKA_ALANI_KAPASITE,
    ZEMIN_TURU,


    /* HAKEM */
    HAKEM_ID,
    HAKEM_ADI_SOYADI,

    HAKEM_GOREVI,

    KLASMAN_ID,
    KLASMAN_TURU,


    ISLEM_TARIHI

FROM SKOR_HESAP;
/



SELECT
    HAFTA,
    FIKSTUR_ID,

    EV_SAHIBI_TAKIM_ADI,
    DEPLASMAN_TAKIM_ADI,

    DAKIKA,

    OYUNCU_ADI_SOYADI
        AS GOLU_ATAN_OYUNCU,

    SKOR_YAPAN_TAKIM_ADI
        AS GOLU_ATAN_TAKIM,

    GOL_SONRASI_SKOR,

    MAC_SONUCU,

    HAKEM_ADI_SOYADI

FROM DE_VW_FUTBOL_SKOR_LOG

WHERE LIG_ID = 1

ORDER BY
    HAFTA,
    FIKSTUR_ID,
    DAKIKA,
    SKOR_LOG_ID;
