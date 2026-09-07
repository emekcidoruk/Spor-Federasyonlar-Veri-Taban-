CREATE OR REPLACE VIEW DE_VW_BASKETBOL_PUAN_DURUMU AS

WITH

/* =========================================================
   1. AYNI TAKIM-LIG ICIN TEK PUAN DURUMU KAYDI
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
                    PD.BASKETBOL_PD_ID DESC
            ) AS RN

        FROM DE_BASKETBOL_PUAN_DURUMU PD
    )
    WHERE RN = 1
),


/* =========================================================
   2. BASKETBOL LIGLERINDEKI BUTUN TAKIMLAR

   FEDERASYON_ID = 2 -> Basketbol

   Puan tablosunda kayýt yoksa bile takým 0 deðerlerle görünür.
   ========================================================= */
BASE0 AS (

    SELECT
        PD.BASKETBOL_PD_ID,

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

        NVL(PD.ATILAN_SAYI, 0)
            AS ATILAN_SAYI,

        NVL(PD.YENILEN_SAYI, 0)
            AS YENILEN_SAYI,

        /*
           Genel sayý farký.
           Basketbolda "Toplam Averaj"
           olarak kullanýyoruz.
        */
        (
            NVL(PD.ATILAN_SAYI, 0)
            -
            NVL(PD.YENILEN_SAYI, 0)
        ) AS TOPLAM_AVERAJ,

        NVL(PD.PUAN, 0)
            AS PUAN,

        PD.ISLEM_TARIHI

    FROM DE_TAKIMLAR T

    JOIN DE_LIGLER L
        ON L.LIG_ID = T.LIG_ID

    LEFT JOIN PD_TEKIL PD
        ON PD.LIG_ID = T.LIG_ID
       AND PD.TAKIM_ID = T.TAKIM_ID

    WHERE L.FEDERASYON_ID = 2
),


/* =========================================================
   3. AYNI PUANDA KAC TAKIM VAR?
   ========================================================= */
BASE AS (

    SELECT
        B.*,

        COUNT(*) OVER (
            PARTITION BY
                B.LIG_ID,
                B.PUAN
        ) AS PUAN_ESIT_TAKIM_SAYISI

    FROM BASE0 B
),


/* =========================================================
   4. OYNANMIS BASKETBOL MACLARINI AL

   MAC_SONUCU:
       85-78
       102-96
       71-69
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
        ) AS EV_SAYI,

        TO_NUMBER(
            REGEXP_SUBSTR(
                TRIM(F.MAC_SONUCU),
                '[0-9]+$'
            )
        ) AS DEP_SAYI

    FROM DE_FIKSTUR F

    WHERE F.FEDERASYON_ID = 2

      AND REGEXP_LIKE(
            TRIM(F.MAC_SONUCU),
            '^[0-9]+-[0-9]+$'
      )
),


/* =========================================================
   5. HER MACI IKI TAKIM ACISINDAN AYIR

   Örnek:
       Fenerbahce Beko 90-80 Efes

   Fenerbahce:
       Attýðý  = 90
       Yediði  = 80
       Ýç puan = 2

   Efes:
       Attýðý  = 80
       Yediði  = 90
       Ýç puan = 1
   ========================================================= */
MAC_TAKIM AS (

    /* ============================
       EV SAHIBI
       ============================ */

    SELECT
        M.LIG_ID,

        M.EV_SAHIBI_TAKIM_ID
            AS TAKIM_ID,

        M.DEPLASMAN_TAKIM_ID
            AS RAKIP_TAKIM_ID,

        M.EV_SAYI
            AS ATILAN_SAYI,

        M.DEP_SAYI
            AS YENILEN_SAYI,

        CASE
            WHEN M.EV_SAYI > M.DEP_SAYI
            THEN 1
            ELSE 0
        END AS GALIBIYET,

        CASE
            WHEN M.EV_SAYI < M.DEP_SAYI
            THEN 1
            ELSE 0
        END AS MAGLUBIYET,

        /*
           Normal basketbol maçý:
           Galibiyet = 2
           Maðlubiyet = 1

           Hükmen maðlubiyet durumu mevcut
           þemada ayrýca tutulmadýðý için burada yok.
        */
        CASE
            WHEN M.EV_SAYI > M.DEP_SAYI
            THEN 2
            ELSE 1
        END AS IC_PUAN

    FROM MAC_SKOR M


    UNION ALL


    /* ============================
       DEPLASMAN
       ============================ */

    SELECT
        M.LIG_ID,

        M.DEPLASMAN_TAKIM_ID
            AS TAKIM_ID,

        M.EV_SAHIBI_TAKIM_ID
            AS RAKIP_TAKIM_ID,

        M.DEP_SAYI
            AS ATILAN_SAYI,

        M.EV_SAYI
            AS YENILEN_SAYI,

        CASE
            WHEN M.DEP_SAYI > M.EV_SAYI
            THEN 1
            ELSE 0
        END AS GALIBIYET,

        CASE
            WHEN M.DEP_SAYI < M.EV_SAYI
            THEN 1
            ELSE 0
        END AS MAGLUBIYET,

        CASE
            WHEN M.DEP_SAYI > M.EV_SAYI
            THEN 2
            ELSE 1
        END AS IC_PUAN

    FROM MAC_SKOR M
),


/* =========================================================
   6. ESIT PUANLI TAKIMLARIN KENDI ARALARINDAKI MACLARI

   Burada sadece:
       Ayný lig
       Ayný genel puan
   olan takýmlar birbirleriyle karþýlaþtýrýlýr.
   ========================================================= */
IC_SONUCLAR AS (

    SELECT
        B.LIG_ID,
        B.TAKIM_ID,

        NVL(
            SUM(M.IC_PUAN),
            0
        ) AS IC_PUAN,

        NVL(
            SUM(M.GALIBIYET),
            0
        ) AS IC_GALIBIYET,

        NVL(
            SUM(M.MAGLUBIYET),
            0
        ) AS IC_MAGLUBIYET,

        NVL(
            SUM(M.ATILAN_SAYI),
            0
        ) AS IC_ATILAN_SAYI,

        NVL(
            SUM(M.YENILEN_SAYI),
            0
        ) AS IC_YENILEN_SAYI,

        /*
           Ýç averaj =
           eþit takýmlarýn kendi arasýndaki
           attýðý - yediði
        */
        NVL(
            SUM(M.ATILAN_SAYI),
            0
        )
        -
        NVL(
            SUM(M.YENILEN_SAYI),
            0
        ) AS IC_AVERAJ

    FROM BASE B

    LEFT JOIN BASE R
        ON R.LIG_ID = B.LIG_ID

       AND R.PUAN = B.PUAN

       AND R.TAKIM_ID <> B.TAKIM_ID


    LEFT JOIN MAC_TAKIM M
        ON M.LIG_ID = B.LIG_ID

       AND M.TAKIM_ID = B.TAKIM_ID

       AND M.RAKIP_TAKIM_ID = R.TAKIM_ID


    GROUP BY
        B.LIG_ID,
        B.TAKIM_ID
),


/* =========================================================
   7. BASKETBOL KURALLARINA GORE SIRALAMA
   ========================================================= */
SIRALI AS (

    SELECT
        B.*,

        NVL(I.IC_PUAN, 0)
            AS IC_PUAN,

        NVL(I.IC_GALIBIYET, 0)
            AS IC_GALIBIYET,

        NVL(I.IC_MAGLUBIYET, 0)
            AS IC_MAGLUBIYET,

        NVL(I.IC_ATILAN_SAYI, 0)
            AS IC_ATILAN_SAYI,

        NVL(I.IC_YENILEN_SAYI, 0)
            AS IC_YENILEN_SAYI,

        NVL(I.IC_AVERAJ, 0)
            AS IC_AVERAJ,


        ROW_NUMBER() OVER (

            PARTITION BY B.LIG_ID

            ORDER BY

                /* =====================================
                   1. GENEL PUAN
                   ===================================== */
                B.PUAN DESC,


                /* =====================================
                   2. ESIT PUANLI TAKIMLARIN
                      KENDI ARALARINDAKI PUANI
                   ===================================== */
                CASE
                    WHEN B.PUAN_ESIT_TAKIM_SAYISI > 1
                    THEN NVL(I.IC_PUAN, 0)
                    ELSE 0
                END DESC,


                /* =====================================
                   3. KENDI ARALARINDAKI SAYI FARKI
                      IC AVERAJ
                   ===================================== */
                CASE
                    WHEN B.PUAN_ESIT_TAKIM_SAYISI > 1
                    THEN NVL(I.IC_AVERAJ, 0)
                    ELSE 0
                END DESC,


                /* =====================================
                   4. KENDI ARALARINDA DAHA FAZLA
                      SAYI ATAN TAKIM
                   ===================================== */
                CASE
                    WHEN B.PUAN_ESIT_TAKIM_SAYISI > 1
                    THEN NVL(I.IC_ATILAN_SAYI, 0)
                    ELSE 0
                END DESC,


                /* =====================================
                   5. BUTUN LIG MACLARINDA
                      TOPLAM AVERAJ
                   ===================================== */
                B.TOPLAM_AVERAJ DESC,


                /* =====================================
                   6. BUTUN MACLARDA
                      DAHA FAZLA SAYI ATAN
                   ===================================== */
                B.ATILAN_SAYI DESC,


                /* =====================================
                   SON TEKNIK FALLBACK

                   Sportif kural deðildir.
                   Tam eþitlikte Oracle'ýn sýralamayý
                   rastgele deðiþtirmemesi için.
                   ===================================== */
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

    ATILAN_SAYI,
    YENILEN_SAYI,

    IC_PUAN,
    IC_AVERAJ,

    IC_ATILAN_SAYI,
    IC_YENILEN_SAYI,

    TOPLAM_AVERAJ,

    PUAN,

    PUAN_ESIT_TAKIM_SAYISI,

    ISLEM_TARIHI

FROM SIRALI;
/




SELECT *
FROM DE_VW_BASKETBOL_PUAN_DURUMU
WHERE LIG_ID = 3
ORDER BY SIRA;
