CREATE OR REPLACE VIEW DE_VW_VOLEYBOL_SKOR_LOG AS

WITH

/* =========================================================
   1. HER MACIN BIRINCI HAKEMINI BUL
   ========================================================= */
BIRINCI_HAKEM AS (

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

    WHERE H.FEDERASYON_ID = 3

      AND (
            UPPER(TRIM(FH.HAKEM_GOREVI)) = 'BIRINCI HAKEM'
         OR UPPER(TRIM(FH.HAKEM_GOREVI)) = 'BÝRÝNCÝ HAKEM'
      )
),


/* =========================================================
   2. VOLEYBOL SKOR LOG DETAYLARI
   ========================================================= */
SKOR_DETAY AS (

    SELECT

        /* SKOR LOG */
        SL.SKOR_LOG_ID,

        SL.FEDERASYON_ID,
        FED.FEDERASYON_ADI,

        /* LIG */
        F.LIG_ID,
        L.LIG_ADI,

        /* FIKSTUR */
        SL.FIKSTUR_ID,
        F.HAFTA,

        /* EV SAHIBI */
        F.EV_SAHIBI_TAKIM_ID,
        EV.TAKIM_ADI
            AS EV_SAHIBI_TAKIM_ADI,

        /* DEPLASMAN */
        F.DEPLASMAN_TAKIM_ID,
        DEP.TAKIM_ADI
            AS DEPLASMAN_TAKIM_ADI,

        /* SKOR KAYDI OLAN TAKIM */
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

        /* OYUNCU */
        SL.OYUNCU_LISANS_NO,
        O.OYUNCU_ADI_SOYADI,
        O.OYUNCU_MEVKI,

        /* SKOR */
        SL.SKOR_TURU,
        SL.SKOR_DEGERI,

        /* SET */
        SL.PERIYOT_SET
            AS SET_NO,

        SL.DAKIKA,

        /* MAC */
        SL.MAC_TARIHI,
        F.MAC_SONUCU,

        /* FINAL SET SKORU */
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

        END AS FINAL_EV_SET,

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

        END AS FINAL_DEP_SET,

        /* MUSABAKA ALANI */
        F.MUSABAKA_ALANI_ID,

        M.MUSABAKA_ALANI_ADI,
        M.MUSABAKA_ALANI_SEHIR,
        M.MUSABAKA_ALANI_ADRESI,
        M.MUSABAKA_ALANI_KAPASITE,
        M.ZEMIN_TURU,

        /* BIRINCI HAKEM */
        BH.HAKEM_ID,

        H.HAKEM_ADI_SOYADI,

        BH.HAKEM_GOREVI,

        H.KLASMAN_ID,

        HK.KLASMAN_TURU,

        SL.ISLEM_TARIHI

    FROM DE_SKOR_LOG SL

    /* SADECE VOLEYBOL */
    JOIN DE_FIKSTUR F
        ON F.FIKSTUR_ID = SL.FIKSTUR_ID
       AND F.FEDERASYON_ID = 3

    JOIN DE_FEDERASYONLAR FED
        ON FED.FEDERASYON_ID =
           F.FEDERASYON_ID

    JOIN DE_LIGLER L
        ON L.LIG_ID =
           F.LIG_ID

    /* SKOR KAYDI OLAN TAKIM */
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

    /* BIRINCI HAKEM */
    LEFT JOIN BIRINCI_HAKEM BH
        ON BH.FIKSTUR_ID =
           F.FIKSTUR_ID
       AND BH.RN = 1

    LEFT JOIN DE_HAKEMLER H
        ON H.HAKEM_ID =
           BH.HAKEM_ID

    LEFT JOIN DE_HAKEM_KLASMAN HK
        ON HK.KLASMAN_ID =
           H.KLASMAN_ID

    /* SADECE SET SKORLARI */
    WHERE UPPER(TRIM(SL.SKOR_TURU)) =
          'SET_PUANI'
),


/* =========================================================
   3. HER SETIN TAM SKORUNU HESAPLA

   Örnek:
       Set 1
       Ev Sahibi : 25
       Deplasman : 21
   ========================================================= */
SET_SKORLARI AS (

    SELECT
        S.FIKSTUR_ID,
        S.SET_NO,

        MAX(S.EV_SAHIBI_TAKIM_ID)
            AS EV_SAHIBI_TAKIM_ID,

        MAX(S.DEPLASMAN_TAKIM_ID)
            AS DEPLASMAN_TAKIM_ID,

        SUM(
            CASE
                WHEN S.TAKIM_ID =
                     S.EV_SAHIBI_TAKIM_ID
                THEN S.SKOR_DEGERI
                ELSE 0
            END
        ) AS EV_SET_PUANI,

        SUM(
            CASE
                WHEN S.TAKIM_ID =
                     S.DEPLASMAN_TAKIM_ID
                THEN S.SKOR_DEGERI
                ELSE 0
            END
        ) AS DEP_SET_PUANI

    FROM SKOR_DETAY S

    GROUP BY
        S.FIKSTUR_ID,
        S.SET_NO
),


/* =========================================================
   4. SET KAZANANINI BUL
   ========================================================= */
SET_SONUCLARI AS (

    SELECT
        S.*,

        CASE

            WHEN S.EV_SET_PUANI >
                 S.DEP_SET_PUANI

            THEN S.EV_SAHIBI_TAKIM_ID


            WHEN S.DEP_SET_PUANI >
                 S.EV_SET_PUANI

            THEN S.DEPLASMAN_TAKIM_ID

        END AS SET_KAZANAN_TAKIM_ID,

        CASE

            WHEN S.EV_SET_PUANI >
                 S.DEP_SET_PUANI
            THEN 'EV SAHIBI'

            WHEN S.DEP_SET_PUANI >
                 S.EV_SET_PUANI
            THEN 'DEPLASMAN'

            ELSE 'ESIT'

        END AS SET_KAZANAN_TARAF

    FROM SET_SKORLARI S
),


/* =========================================================
   5. HER SET SONUNDA MACIN SET SKORUNU HESAPLA

   Örnek:
       Set 1 -> 1-0
       Set 2 -> 1-1
       Set 3 -> 2-1
       Set 4 -> 3-1
   ========================================================= */
SET_AKIS AS (

    SELECT
        S.*,

        SUM(
            CASE
                WHEN S.SET_KAZANAN_TAKIM_ID =
                     S.EV_SAHIBI_TAKIM_ID
                THEN 1
                ELSE 0
            END
        ) OVER (

            PARTITION BY S.FIKSTUR_ID

            ORDER BY S.SET_NO

            ROWS BETWEEN
                UNBOUNDED PRECEDING
                AND CURRENT ROW

        ) AS SET_SONRASI_EV_SET,


        SUM(
            CASE
                WHEN S.SET_KAZANAN_TAKIM_ID =
                     S.DEPLASMAN_TAKIM_ID
                THEN 1
                ELSE 0
            END
        ) OVER (

            PARTITION BY S.FIKSTUR_ID

            ORDER BY S.SET_NO

            ROWS BETWEEN
                UNBOUNDED PRECEDING
                AND CURRENT ROW

        ) AS SET_SONRASI_DEP_SET

    FROM SET_SONUCLARI S
),


/* =========================================================
   6. SKOR LOG SATIRLARINI SET SONUCLARIYLA BIRLESTIR
   ========================================================= */
SONUC AS (

    SELECT
        D.*,

        SA.EV_SET_PUANI,
        SA.DEP_SET_PUANI,

        SA.SET_KAZANAN_TAKIM_ID,

        K.TAKIM_ADI
            AS SET_KAZANAN_TAKIM_ADI,

        SA.SET_KAZANAN_TARAF,

        SA.SET_SONRASI_EV_SET,
        SA.SET_SONRASI_DEP_SET,


        /* =================================================
           TAKIM BU SETI KAZANDI MI?
           ================================================= */
        CASE

            WHEN D.TAKIM_ID =
                 SA.SET_KAZANAN_TAKIM_ID
            THEN 'KAZANDI'

            ELSE 'KAYBETTI'

        END AS TAKIM_SET_SONUCU,


        /* =================================================
           TAKIMIN MAC BOYUNCA ALDIGI TOPLAM SAYI
           ================================================= */
        SUM(D.SKOR_DEGERI) OVER (

            PARTITION BY
                D.FIKSTUR_ID,
                D.TAKIM_ID

        ) AS TAKIM_MAC_TOPLAM_SAYI,


        /* =================================================
           TAKIMIN LIG BOYUNCA ALDIGI TOPLAM SAYI
           ================================================= */
        SUM(D.SKOR_DEGERI) OVER (

            PARTITION BY
                D.LIG_ID,
                D.TAKIM_ID

        ) AS TAKIM_LIG_TOPLAM_SAYI

    FROM SKOR_DETAY D

    JOIN SET_AKIS SA
        ON SA.FIKSTUR_ID =
           D.FIKSTUR_ID

       AND SA.SET_NO =
           D.SET_NO

    LEFT JOIN DE_TAKIMLAR K
        ON K.TAKIM_ID =
           SA.SET_KAZANAN_TAKIM_ID
)


/* =========================================================
   7. VIEW SONUCU
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


    /* SKOR KAYDI OLAN TAKIM */
    TAKIM_ID,
    SKOR_YAPAN_TAKIM_ADI,
    TAKIM_TARAFI,


    /* OYUNCU */
    OYUNCU_LISANS_NO,
    OYUNCU_ADI_SOYADI,
    OYUNCU_MEVKI,


    /* SET */
    SET_NO,

    SKOR_TURU,
    SKOR_DEGERI,


    /* =====================================================
       SET SKORU

       Örnek: 25-21
       ===================================================== */
    EV_SET_PUANI,
    DEP_SET_PUANI,

    EV_SET_PUANI
        || '-'
        || DEP_SET_PUANI
        AS SET_SKORU,


    /* SET KAZANANI */
    SET_KAZANAN_TAKIM_ID,
    SET_KAZANAN_TAKIM_ADI,
    SET_KAZANAN_TARAF,

    TAKIM_SET_SONUCU,


    /* =====================================================
       SET BITTIKTEN SONRA MAC SKORU

       Örnek:
       Set 1 -> 1-0
       Set 2 -> 1-1
       Set 3 -> 2-1
       Set 4 -> 3-1
       ===================================================== */
    SET_SONRASI_EV_SET,
    SET_SONRASI_DEP_SET,

    SET_SONRASI_EV_SET
        || '-'
        || SET_SONRASI_DEP_SET
        AS SET_SONRASI_MAC_SKORU,


    /* FINAL MAC SKORU */
    FINAL_EV_SET,
    FINAL_DEP_SET,

    MAC_SONUCU,


    /* TAKIM ISTATISTIGI */
    TAKIM_MAC_TOPLAM_SAYI,
    TAKIM_LIG_TOPLAM_SAYI,


    /* ZAMAN */
    DAKIKA,
    MAC_TARIHI,


    /* MUSABAKA ALANI */
    MUSABAKA_ALANI_ID,
    MUSABAKA_ALANI_ADI,
    MUSABAKA_ALANI_SEHIR,
    MUSABAKA_ALANI_ADRESI,
    MUSABAKA_ALANI_KAPASITE,
    ZEMIN_TURU,


    /* BIRINCI HAKEM */
    HAKEM_ID,
    HAKEM_ADI_SOYADI,
    HAKEM_GOREVI,

    KLASMAN_ID,
    KLASMAN_TURU,


    ISLEM_TARIHI

FROM SONUC;
/




SELECT
    LIG_ADI,
    HAFTA,

    EV_SAHIBI_TAKIM_ADI,
    DEPLASMAN_TAKIM_ADI,

    SET_NO,

    SKOR_YAPAN_TAKIM_ADI,
    SKOR_DEGERI,

    SET_SKORU,

    SET_KAZANAN_TAKIM_ADI,

    SET_SONRASI_MAC_SKORU,

    HAKEM_ADI_SOYADI,

    MUSABAKA_ALANI_ADI,

    MAC_SONUCU

FROM DE_VW_VOLEYBOL_SKOR_LOG

ORDER BY
    LIG_ID,
    HAFTA,
    FIKSTUR_ID,
    SET_NO,
    TAKIM_ID;
