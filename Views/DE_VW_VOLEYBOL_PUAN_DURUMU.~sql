CREATE OR REPLACE VIEW DE_VW_VOLEYBOL_PUAN_DURUMU AS

WITH

/* =========================================================
   1. AYNI TAKIM + LIG ICIN TEK PUAN DURUMU SATIRI
   ========================================================= */
PD_TEKIL AS (

    SELECT *
    FROM (
        SELECT
            PD.*,

            ROW_NUMBER() OVER (
                PARTITION BY
                    PD.LIG_ID,
                    PD.TAKIM_ID
                ORDER BY
                    PD.ISLEM_TARIHI DESC NULLS LAST,
                    PD.VOLEYBOL_PD_ID DESC
            ) AS RN

        FROM DE_VOLEYBOL_PUAN_DURUMU PD
    )
    WHERE RN = 1
),


/* =========================================================
   2. VOLEYBOL LIGLERINDEKI BUTUN TAKIMLAR

   Puan durumunda kayýt yoksa bile takým 0 deðerle görünür.
   ========================================================= */
BASE0 AS (

    SELECT
        PD.VOLEYBOL_PD_ID,

        L.FEDERASYON_ID,

        L.LIG_ID,
        L.LIG_ADI,

        T.TAKIM_ID,
        T.TAKIM_ADI,

        NVL(PD.OYNANAN_MAC, 0)
            AS OYNANAN_MAC,

        NVL(PD.GALIBIYET, 0)
            AS GALIBIYET,

        NVL(PD.MAGLUBIYET, 0)
            AS MAGLUBIYET,

        NVL(PD.ALINAN_SET, 0)
            AS ALINAN_SET,

        NVL(PD.VERILEN_SET, 0)
            AS VERILEN_SET,

        NVL(PD.ALINAN_SAYI_PUANI, 0)
            AS ALINAN_SAYI_PUANI,

        NVL(PD.VERILEN_SAYI_PUANI, 0)
            AS VERILEN_SAYI_PUANI,

        NVL(PD.PUAN, 0)
            AS PUAN,

        PD.ISLEM_TARIHI

    FROM DE_TAKIMLAR T

    JOIN DE_LIGLER L
        ON L.LIG_ID = T.LIG_ID

    LEFT JOIN PD_TEKIL PD
        ON PD.LIG_ID = T.LIG_ID
       AND PD.TAKIM_ID = T.TAKIM_ID

    /* VOLEYBOL FEDERASYONU */
    WHERE L.FEDERASYON_ID = 3
),


/* =========================================================
   3. SET ORANI VE SAYI ORANI

   Set oraný:
       alýnan set / verilen set

   Sayý oraný:
       alýnan sayý / verilen sayý

   Verilen deðer 0 ise sýfýra bölme hatasý engellenir.
   ========================================================= */
BASE1 AS (

    SELECT
        B.*,

        CASE
            WHEN B.VERILEN_SET = 0
                 AND B.ALINAN_SET > 0
            THEN 999999999

            WHEN B.VERILEN_SET = 0
            THEN 0

            ELSE
                B.ALINAN_SET / B.VERILEN_SET
        END AS SET_ORANI_HESAP,


        CASE
            WHEN B.VERILEN_SAYI_PUANI = 0
                 AND B.ALINAN_SAYI_PUANI > 0
            THEN 999999999

            WHEN B.VERILEN_SAYI_PUANI = 0
            THEN 0

            ELSE
                B.ALINAN_SAYI_PUANI /
                B.VERILEN_SAYI_PUANI
        END AS SAYI_ORANI_HESAP

    FROM BASE0 B
),


/* =========================================================
   4. GENEL KRITERLERIN TAMAMI ESIT OLAN TAKIMLARI BUL

   TVF:
   1- Galibiyet
   2- Puan
   3- Set oraný
   4- Sayý oraný

   Bunlarýn tamamý eþitse ikili/çoklu sonuçlara geçilecek.
   ========================================================= */
BASE AS (

    SELECT
        B.*,

        COUNT(*) OVER (
            PARTITION BY
                B.LIG_ID,
                B.GALIBIYET,
                B.PUAN,
                B.SET_ORANI_HESAP,
                B.SAYI_ORANI_HESAP
        ) AS TAM_ESIT_TAKIM_SAYISI

    FROM BASE1 B
),


/* =========================================================
   5. OYNANMIS VOLEYBOL MACLARI

   MAC_SONUCU örnekleri:
       3-0
       3-1
       3-2
       2-3
       1-3
       0-3
   ========================================================= */
MAC_SKOR AS (

    SELECT
        F.FIKSTUR_ID,

        F.LIG_ID,

        F.EV_SAHIBI_TAKIM_ID,
        F.DEPLASMAN_TAKIM_ID,

        TO_NUMBER(
            REGEXP_SUBSTR(
                TRIM(F.MAC_SONUCU),
                '^[0-9]+'
            )
        ) AS EV_SET,

        TO_NUMBER(
            REGEXP_SUBSTR(
                TRIM(F.MAC_SONUCU),
                '[0-9]+$'
            )
        ) AS DEP_SET

    FROM DE_FIKSTUR F

    WHERE F.FEDERASYON_ID = 3

      AND REGEXP_LIKE(
            TRIM(F.MAC_SONUCU),
            '^[0-9]+-[0-9]+$'
      )
),


/* =========================================================
   6. SKOR LOGDAN TAKIMLARIN MAC ICINDEKI TOPLAM SAYILARI

   DE_SKOR_LOG:
       SKOR_TURU = 'SET_PUANI'

   Örnek:
       25-20
       23-25
       25-18
       25-21

   Takým toplamlarý burada hesaplanýr.
   ========================================================= */
MAC_SAYILARI AS (

    SELECT
        S.FIKSTUR_ID,
        S.TAKIM_ID,

        SUM(S.SKOR_DEGERI)
            AS TOPLAM_SAYI

    FROM DE_SKOR_LOG S

    WHERE UPPER(TRIM(S.SKOR_TURU)) = 'SET_PUANI'

    GROUP BY
        S.FIKSTUR_ID,
        S.TAKIM_ID
),


/* =========================================================
   7. HER MACI IKI TAKIM ACISINDAN AYIR
   ========================================================= */
MAC_TAKIM AS (

    /* ==========================
       EV SAHIBI
       ========================== */

    SELECT
        M.FIKSTUR_ID,

        M.LIG_ID,

        M.EV_SAHIBI_TAKIM_ID
            AS TAKIM_ID,

        M.DEPLASMAN_TAKIM_ID
            AS RAKIP_TAKIM_ID,

        M.EV_SET
            AS ALINAN_SET,

        M.DEP_SET
            AS VERILEN_SET,

        NVL(SE.TOPLAM_SAYI, 0)
            AS ALINAN_SAYI,

        NVL(SD.TOPLAM_SAYI, 0)
            AS VERILEN_SAYI,


        /* GALIBIYET */
        CASE
            WHEN M.EV_SET = 3
            THEN 1
            ELSE 0
        END AS GALIBIYET,


        /* TVF PUAN SISTEMI */
        CASE

            WHEN M.EV_SET = 3
                 AND M.DEP_SET IN (0, 1)
            THEN 3

            WHEN M.EV_SET = 3
                 AND M.DEP_SET = 2
            THEN 2

            WHEN M.EV_SET = 2
                 AND M.DEP_SET = 3
            THEN 1

            ELSE 0

        END AS PUAN

    FROM MAC_SKOR M

    LEFT JOIN MAC_SAYILARI SE
        ON SE.FIKSTUR_ID = M.FIKSTUR_ID
       AND SE.TAKIM_ID = M.EV_SAHIBI_TAKIM_ID

    LEFT JOIN MAC_SAYILARI SD
        ON SD.FIKSTUR_ID = M.FIKSTUR_ID
       AND SD.TAKIM_ID = M.DEPLASMAN_TAKIM_ID


    UNION ALL


    /* ==========================
       DEPLASMAN
       ========================== */

    SELECT
        M.FIKSTUR_ID,

        M.LIG_ID,

        M.DEPLASMAN_TAKIM_ID
            AS TAKIM_ID,

        M.EV_SAHIBI_TAKIM_ID
            AS RAKIP_TAKIM_ID,

        M.DEP_SET
            AS ALINAN_SET,

        M.EV_SET
            AS VERILEN_SET,

        NVL(SD.TOPLAM_SAYI, 0)
            AS ALINAN_SAYI,

        NVL(SE.TOPLAM_SAYI, 0)
            AS VERILEN_SAYI,


        CASE
            WHEN M.DEP_SET = 3
            THEN 1
            ELSE 0
        END AS GALIBIYET,


        CASE

            WHEN M.DEP_SET = 3
                 AND M.EV_SET IN (0, 1)
            THEN 3

            WHEN M.DEP_SET = 3
                 AND M.EV_SET = 2
            THEN 2

            WHEN M.DEP_SET = 2
                 AND M.EV_SET = 3
            THEN 1

            ELSE 0

        END AS PUAN

    FROM MAC_SKOR M

    LEFT JOIN MAC_SAYILARI SE
        ON SE.FIKSTUR_ID = M.FIKSTUR_ID
       AND SE.TAKIM_ID = M.EV_SAHIBI_TAKIM_ID

    LEFT JOIN MAC_SAYILARI SD
        ON SD.FIKSTUR_ID = M.FIKSTUR_ID
       AND SD.TAKIM_ID = M.DEPLASMAN_TAKIM_ID
),


/* =========================================================
   8. TAMAMEN ESIT TAKIMLARIN KENDI ARALARINDAKI MACLARI

   TVF son eþitlik kriteri:
       1. Kendi aralarýnda galibiyet
       2. Kendi aralarýnda puan
       3. Kendi aralarýnda set oraný
       4. Kendi aralarýnda sayý oraný
   ========================================================= */
IC_HAM AS (

    SELECT
        B.LIG_ID,
        B.TAKIM_ID,

        NVL(
            SUM(M.GALIBIYET),
            0
        ) AS IC_GALIBIYET,

        NVL(
            SUM(M.PUAN),
            0
        ) AS IC_PUAN,

        NVL(
            SUM(M.ALINAN_SET),
            0
        ) AS IC_ALINAN_SET,

        NVL(
            SUM(M.VERILEN_SET),
            0
        ) AS IC_VERILEN_SET,

        NVL(
            SUM(M.ALINAN_SAYI),
            0
        ) AS IC_ALINAN_SAYI,

        NVL(
            SUM(M.VERILEN_SAYI),
            0
        ) AS IC_VERILEN_SAYI

    FROM BASE B

    LEFT JOIN BASE R

        ON R.LIG_ID = B.LIG_ID

       AND R.TAKIM_ID <> B.TAKIM_ID

       /* Genel kriterlerin hepsi eþit olmalý */

       AND R.GALIBIYET =
           B.GALIBIYET

       AND R.PUAN =
           B.PUAN

       AND R.SET_ORANI_HESAP =
           B.SET_ORANI_HESAP

       AND R.SAYI_ORANI_HESAP =
           B.SAYI_ORANI_HESAP


    LEFT JOIN MAC_TAKIM M

        ON M.LIG_ID =
           B.LIG_ID

       AND M.TAKIM_ID =
           B.TAKIM_ID

       AND M.RAKIP_TAKIM_ID =
           R.TAKIM_ID


    GROUP BY
        B.LIG_ID,
        B.TAKIM_ID
),


/* =========================================================
   9. IKILI / COKLU SET VE SAYI ORANLARI
   ========================================================= */
IC_SONUCLAR AS (

    SELECT
        I.*,


        CASE

            WHEN I.IC_VERILEN_SET = 0
                 AND I.IC_ALINAN_SET > 0
            THEN 999999999

            WHEN I.IC_VERILEN_SET = 0
            THEN 0

            ELSE
                I.IC_ALINAN_SET /
                I.IC_VERILEN_SET

        END AS IC_SET_ORANI,


        CASE

            WHEN I.IC_VERILEN_SAYI = 0
                 AND I.IC_ALINAN_SAYI > 0
            THEN 999999999

            WHEN I.IC_VERILEN_SAYI = 0
            THEN 0

            ELSE
                I.IC_ALINAN_SAYI /
                I.IC_VERILEN_SAYI

        END AS IC_SAYI_ORANI

    FROM IC_HAM I
),


/* =========================================================
   10. TVF KURALLARINA GORE SIRALA
   ========================================================= */
SIRALI AS (

    SELECT
        B.*,

        NVL(I.IC_GALIBIYET, 0)
            AS IC_GALIBIYET,

        NVL(I.IC_PUAN, 0)
            AS IC_PUAN,

        NVL(I.IC_ALINAN_SET, 0)
            AS IC_ALINAN_SET,

        NVL(I.IC_VERILEN_SET, 0)
            AS IC_VERILEN_SET,

        NVL(I.IC_SET_ORANI, 0)
            AS IC_SET_ORANI,

        NVL(I.IC_ALINAN_SAYI, 0)
            AS IC_ALINAN_SAYI,

        NVL(I.IC_VERILEN_SAYI, 0)
            AS IC_VERILEN_SAYI,

        NVL(I.IC_SAYI_ORANI, 0)
            AS IC_SAYI_ORANI,


        ROW_NUMBER() OVER (

            PARTITION BY B.LIG_ID

            ORDER BY

                /* =====================================
                   1. GALIBIYET SAYISI
                   TVF'de ilk kriter budur.
                   ===================================== */
                B.GALIBIYET DESC,


                /* =====================================
                   2. TOPLAM PUAN
                   ===================================== */
                B.PUAN DESC,


                /* =====================================
                   3. GENEL SET ORANI
                   ALINAN SET / VERILEN SET
                   ===================================== */
                B.SET_ORANI_HESAP DESC,


                /* =====================================
                   4. GENEL SAYI ORANI
                   ALINAN SAYI / VERILEN SAYI
                   ===================================== */
                B.SAYI_ORANI_HESAP DESC,


                /* =====================================
                   GENEL KRITERLER HALA ESITSE:

                   5. KENDI ARALARINDA GALIBIYET
                   ===================================== */
                CASE
                    WHEN B.TAM_ESIT_TAKIM_SAYISI > 1
                    THEN NVL(I.IC_GALIBIYET, 0)
                    ELSE 0
                END DESC,


                /* =====================================
                   6. KENDI ARALARINDA PUAN
                   ===================================== */
                CASE
                    WHEN B.TAM_ESIT_TAKIM_SAYISI > 1
                    THEN NVL(I.IC_PUAN, 0)
                    ELSE 0
                END DESC,


                /* =====================================
                   7. KENDI ARALARINDA SET ORANI
                   ===================================== */
                CASE
                    WHEN B.TAM_ESIT_TAKIM_SAYISI > 1
                    THEN NVL(I.IC_SET_ORANI, 0)
                    ELSE 0
                END DESC,


                /* =====================================
                   8. KENDI ARALARINDA SAYI ORANI
                   ===================================== */
                CASE
                    WHEN B.TAM_ESIT_TAKIM_SAYISI > 1
                    THEN NVL(I.IC_SAYI_ORANI, 0)
                    ELSE 0
                END DESC,


                /* Teknik fallback */
                B.TAKIM_ID ASC

        ) AS SIRA

    FROM BASE B

    LEFT JOIN IC_SONUCLAR I
        ON I.LIG_ID = B.LIG_ID
       AND I.TAKIM_ID = B.TAKIM_ID
)


/* =========================================================
   VIEW SONUCU
   ========================================================= */
SELECT
    SIRA,

    FEDERASYON_ID,

    LIG_ID,
    LIG_ADI,

    TAKIM_ID,
    TAKIM_ADI,

    OYNANAN_MAC,

    GALIBIYET,
    MAGLUBIYET,

    ALINAN_SET,
    VERILEN_SET,

    ROUND(
        SET_ORANI_HESAP,
        4
    ) AS SET_ORANI,

    ALINAN_SAYI_PUANI,
    VERILEN_SAYI_PUANI,

    ROUND(
        SAYI_ORANI_HESAP,
        4
    ) AS SAYI_PUANI_ORANI,

    PUAN,

    /* EÞÝTLÝK KONTROLÜ ÝÇÝN */
    IC_GALIBIYET,
    IC_PUAN,

    IC_ALINAN_SET,
    IC_VERILEN_SET,

    ROUND(
        IC_SET_ORANI,
        4
    ) AS IC_SET_ORANI,

    IC_ALINAN_SAYI,
    IC_VERILEN_SAYI,

    ROUND(
        IC_SAYI_ORANI,
        4
    ) AS IC_SAYI_ORANI,

    ISLEM_TARIHI

FROM SIRALI;
/



SELECT *
FROM DE_VW_VOLEYBOL_PUAN_DURUMU
WHERE LIG_ID = 5
ORDER BY SIRA;
