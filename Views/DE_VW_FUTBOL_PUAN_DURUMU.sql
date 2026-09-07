CREATE OR REPLACE VIEW DE_VW_FUTBOL_PUAN_DURUMU AS

WITH

/* =========================================================
   1. PUAN DURUMUNUN TEMEL VERILERI
   ========================================================= */
BASE0 AS (

    SELECT
        PD.FUTBOL_PD_ID,

        L.FEDERASYON_ID,

        PD.LIG_ID,
        L.LIG_ADI,

        PD.TAKIM_ID,
        T.TAKIM_ADI,

        PD.GALIBIYET,
        PD.BERABERLIK,
        PD.MAGLUBIYET,

        (
            PD.GALIBIYET +
            PD.BERABERLIK +
            PD.MAGLUBIYET
        ) AS OYNANAN_MAC,

        PD.ATILAN_GOL,
        PD.YENILEN_GOL,

        (
            PD.ATILAN_GOL -
            PD.YENILEN_GOL
        ) AS GENEL_AVERAJ,

        PD.PUAN,

        PD.ISLEM_TARIHI

    FROM DE_FUTBOL_PUAN_DURUMU PD

    JOIN DE_TAKIMLAR T
        ON T.TAKIM_ID = PD.TAKIM_ID

    JOIN DE_LIGLER L
        ON L.LIG_ID = PD.LIG_ID
),


/* =========================================================
   2. AYNI PUANDA KAC TAKIM VAR?
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
   3. FIKSTURDEKI OYNANMIS FUTBOL MACLARININ SKORLARINI AYIR
   MAC_SONUCU ORNEK:
       2-1
       0-0
       4-2
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
        ) AS EV_GOL,

        TO_NUMBER(
            REGEXP_SUBSTR(
                TRIM(F.MAC_SONUCU),
                '[0-9]+$'
            )
        ) AS DEP_GOL

    FROM DE_FIKSTUR F

    WHERE REGEXP_LIKE(
        TRIM(F.MAC_SONUCU),
        '^[0-9]+-[0-9]+$'
    )
),


/* =========================================================
   4. HER MACI TAKIM BAKIS ACISINDAN IKI SATIRA CEVIR

   ÖRNEK:
       Fenerbahce 2-1 Galatasaray

   Fenerbahce -> attigi 2 / yedigi 1 / 3 puan
   Galatasaray -> attigi 1 / yedigi 2 / 0 puan
   ========================================================= */
MAC_TAKIM AS (

    /* EV SAHIBI */

    SELECT
        M.LIG_ID,

        M.EV_SAHIBI_TAKIM_ID AS TAKIM_ID,
        M.DEPLASMAN_TAKIM_ID AS RAKIP_TAKIM_ID,

        M.EV_GOL AS ATILAN_GOL,
        M.DEP_GOL AS YENILEN_GOL,

        CASE
            WHEN M.EV_GOL > M.DEP_GOL THEN 3
            WHEN M.EV_GOL = M.DEP_GOL THEN 1
            ELSE 0
        END AS PUAN

    FROM MAC_SKOR M


    UNION ALL


    /* DEPLASMAN */

    SELECT
        M.LIG_ID,

        M.DEPLASMAN_TAKIM_ID AS TAKIM_ID,
        M.EV_SAHIBI_TAKIM_ID AS RAKIP_TAKIM_ID,

        M.DEP_GOL AS ATILAN_GOL,
        M.EV_GOL AS YENILEN_GOL,

        CASE
            WHEN M.DEP_GOL > M.EV_GOL THEN 3
            WHEN M.DEP_GOL = M.EV_GOL THEN 1
            ELSE 0
        END AS PUAN

    FROM MAC_SKOR M
),


/* =========================================================
   5. PUANI ESIT TAKIMLARIN KENDI ARALARINDAKI SONUCLARI

   TFF IKILI / COKLU AVERAJ MANTIGI
   ========================================================= */
IKILI_PUAN AS (

    SELECT
        B.LIG_ID,
        B.TAKIM_ID,

        NVL(
            SUM(M.PUAN),
            0
        ) AS IKILI_PUAN,

        NVL(
            SUM(M.ATILAN_GOL),
            0
        ) AS IKILI_ATILAN_GOL,

        NVL(
            SUM(M.YENILEN_GOL),
            0
        ) AS IKILI_YENILEN_GOL,

        NVL(
            SUM(M.ATILAN_GOL),
            0
        )
        -
        NVL(
            SUM(M.YENILEN_GOL),
            0
        ) AS IKILI_AVERAJ

    FROM BASE B

    LEFT JOIN BASE R
        ON R.LIG_ID = B.LIG_ID

       /* SADECE AYNI PUANDAKI RAKIPLER */
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
   6. FUTBOL KURALLARINA GORE SIRALAMA
   ========================================================= */
SIRALI AS (

    SELECT
        B.*,

        NVL(
            I.IKILI_PUAN,
            0
        ) AS IKILI_PUAN,

        NVL(
            I.IKILI_ATILAN_GOL,
            0
        ) AS IKILI_ATILAN_GOL,

        NVL(
            I.IKILI_YENILEN_GOL,
            0
        ) AS IKILI_YENILEN_GOL,

        NVL(
            I.IKILI_AVERAJ,
            0
        ) AS IKILI_AVERAJ,


        ROW_NUMBER() OVER (

            PARTITION BY B.LIG_ID

            ORDER BY

                /* =========================================
                   1. GENEL PUAN
                   ========================================= */
                B.PUAN DESC,


                /* =========================================
                   2. PUAN ESITSE:
                      KENDI ARALARINDAKI PUAN
                   ========================================= */
                CASE
                    WHEN B.PUAN_ESIT_TAKIM_SAYISI > 1
                    THEN NVL(I.IKILI_PUAN, 0)
                    ELSE 0
                END DESC,


                /* =========================================
                   3. IKILI / COKLU AVERAJ
                   ========================================= */
                CASE
                    WHEN B.PUAN_ESIT_TAKIM_SAYISI > 1
                    THEN NVL(I.IKILI_AVERAJ, 0)
                    ELSE 0
                END DESC,


                /* =========================================
                   4. 3 VEYA DAHA FAZLA TAKIM PUAN ESITSE
                      MINI PUAN CETVELINDE ATILAN GOL
                   ========================================= */
                CASE
                    WHEN B.PUAN_ESIT_TAKIM_SAYISI >= 3
                    THEN NVL(I.IKILI_ATILAN_GOL, 0)
                    ELSE 0
                END DESC,


                /* =========================================
                   5. GENEL AVERAJ
                   ========================================= */
                B.GENEL_AVERAJ DESC,


                /* =========================================
                   6. GENELDE DAHA FAZLA ATILAN GOL
                   ========================================= */
                B.ATILAN_GOL DESC,


                /* =========================================
                   SON TEKNIK TIE BREAK
                   Oracle sonucu kararsiz kalmasin diye.
                   Sportif bir TFF kurali DEGILDIR.
                   ========================================= */
                B.TAKIM_ID ASC

        ) AS SIRA

    FROM BASE B

    LEFT JOIN IKILI_PUAN I
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
    BERABERLIK,
    MAGLUBIYET,

    ATILAN_GOL,
    YENILEN_GOL,

    GENEL_AVERAJ AS AVERAJ,

    PUAN,

    /* PUAN ESITLIGI KONTROLU ICIN */
    IKILI_PUAN,
    IKILI_ATILAN_GOL,
    IKILI_YENILEN_GOL,
    IKILI_AVERAJ,

    PUAN_ESIT_TAKIM_SAYISI,

    ISLEM_TARIHI

FROM SIRALI;
/



SELECT *
FROM DE_VW_FUTBOL_PUAN_DURUMU
WHERE LIG_ID = 1
ORDER BY SIRA;
