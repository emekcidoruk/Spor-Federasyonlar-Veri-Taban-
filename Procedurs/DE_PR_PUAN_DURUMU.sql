CREATE OR REPLACE PROCEDURE DE_PUAN_DURUMU_HESAPLA (
    P_LIG_ID IN NUMBER
)
AS

    V_FED NUMBER;

    V_O NUMBER;
    V_G NUMBER;
    V_B NUMBER;
    V_M NUMBER;

    V_A NUMBER;
    V_Y NUMBER;

    V_PUAN NUMBER;

    V_SET_ORANI NUMBER;

    V_ALINAN_SAYI NUMBER;
    V_VERILEN_SAYI NUMBER;
    V_SAYI_ORANI NUMBER;

BEGIN

    SELECT FEDERASYON_ID
    INTO V_FED
    FROM DE_LIGLER
    WHERE LIG_ID =
          P_LIG_ID;


    FOR T IN (

        SELECT TAKIM_ID

        FROM DE_TAKIMLAR

        WHERE LIG_ID =
              P_LIG_ID

        ORDER BY TAKIM_ID

    )
    LOOP


        /* =================================================
           FUTBOL
           ================================================= */

        IF V_FED = 1 THEN


            SELECT

                NVL(SUM(
                    CASE
                        WHEN ATILAN > YENILEN THEN 1
                        ELSE 0
                    END
                ),0),

                NVL(SUM(
                    CASE
                        WHEN ATILAN = YENILEN THEN 1
                        ELSE 0
                    END
                ),0),

                NVL(SUM(
                    CASE
                        WHEN ATILAN < YENILEN THEN 1
                        ELSE 0
                    END
                ),0),

                NVL(SUM(ATILAN),0),

                NVL(SUM(YENILEN),0)

            INTO
                V_G,
                V_B,
                V_M,
                V_A,
                V_Y

            FROM (

                SELECT

                    TO_NUMBER(
                        REGEXP_SUBSTR(
                            MAC_SONUCU,
                            '^[0-9]+'
                        )
                    ) ATILAN,

                    TO_NUMBER(
                        REGEXP_SUBSTR(
                            MAC_SONUCU,
                            '[0-9]+$'
                        )
                    ) YENILEN

                FROM DE_FIKSTUR

                WHERE LIG_ID = P_LIG_ID

                  AND EV_SAHIBI_TAKIM_ID =
                      T.TAKIM_ID

                  AND UPPER(TRIM(MAC_SONUCU))
                      <> 'OYNANMADI'


                UNION ALL


                SELECT

                    TO_NUMBER(
                        REGEXP_SUBSTR(
                            MAC_SONUCU,
                            '[0-9]+$'
                        )
                    ),

                    TO_NUMBER(
                        REGEXP_SUBSTR(
                            MAC_SONUCU,
                            '^[0-9]+'
                        )
                    )

                FROM DE_FIKSTUR

                WHERE LIG_ID = P_LIG_ID

                  AND DEPLASMAN_TAKIM_ID =
                      T.TAKIM_ID

                  AND UPPER(TRIM(MAC_SONUCU))
                      <> 'OYNANMADI'

            );


            V_PUAN :=
                V_G * 3 +
                V_B;


            UPDATE DE_FUTBOL_PUAN_DURUMU

            SET
                GALIBIYET   = V_G,
                BERABERLIK  = V_B,
                MAGLUBIYET  = V_M,
                ATILAN_GOL  = V_A,
                YENILEN_GOL = V_Y,
                PUAN        = V_PUAN

            WHERE LIG_ID =
                  P_LIG_ID

              AND TAKIM_ID =
                  T.TAKIM_ID;


            IF SQL%ROWCOUNT = 0 THEN

                INSERT INTO DE_FUTBOL_PUAN_DURUMU (
                    LIG_ID,
                    TAKIM_ID,
                    GALIBIYET,
                    BERABERLIK,
                    MAGLUBIYET,
                    ATILAN_GOL,
                    YENILEN_GOL,
                    PUAN
                )
                VALUES (
                    P_LIG_ID,
                    T.TAKIM_ID,
                    V_G,
                    V_B,
                    V_M,
                    V_A,
                    V_Y,
                    V_PUAN
                );

            END IF;



        /* =================================================
           BASKETBOL
           ================================================= */

        ELSIF V_FED = 2 THEN


            SELECT

                COUNT(*),

                NVL(SUM(
                    CASE
                        WHEN ATILAN > YENILEN THEN 1
                        ELSE 0
                    END
                ),0),

                NVL(SUM(
                    CASE
                        WHEN ATILAN < YENILEN THEN 1
                        ELSE 0
                    END
                ),0),

                NVL(SUM(ATILAN),0),

                NVL(SUM(YENILEN),0)

            INTO
                V_O,
                V_G,
                V_M,
                V_A,
                V_Y

            FROM (

                SELECT

                    TO_NUMBER(
                        REGEXP_SUBSTR(
                            MAC_SONUCU,
                            '^[0-9]+'
                        )
                    ) ATILAN,

                    TO_NUMBER(
                        REGEXP_SUBSTR(
                            MAC_SONUCU,
                            '[0-9]+$'
                        )
                    ) YENILEN

                FROM DE_FIKSTUR

                WHERE LIG_ID =
                      P_LIG_ID

                  AND EV_SAHIBI_TAKIM_ID =
                      T.TAKIM_ID

                  AND UPPER(TRIM(MAC_SONUCU))
                      <> 'OYNANMADI'


                UNION ALL


                SELECT

                    TO_NUMBER(
                        REGEXP_SUBSTR(
                            MAC_SONUCU,
                            '[0-9]+$'
                        )
                    ),

                    TO_NUMBER(
                        REGEXP_SUBSTR(
                            MAC_SONUCU,
                            '^[0-9]+'
                        )
                    )

                FROM DE_FIKSTUR

                WHERE LIG_ID =
                      P_LIG_ID

                  AND DEPLASMAN_TAKIM_ID =
                      T.TAKIM_ID

                  AND UPPER(TRIM(MAC_SONUCU))
                      <> 'OYNANMADI'

            );


            V_PUAN :=
                V_G * 2 +
                V_M;


            UPDATE DE_BASKETBOL_PUAN_DURUMU

            SET
                OYNANAN_MAC   = V_O,
                GALIBIYET     = V_G,
                MAGLUBIYET    = V_M,
                ATILAN_SAYI   = V_A,
                YENILEN_SAYI  = V_Y,
                IC_AVERAJ     = 0,
                IC_PUAN       = 0,
                TOPLAM_AVERAJ = V_A - V_Y,
                PUAN          = V_PUAN

            WHERE LIG_ID =
                  P_LIG_ID

              AND TAKIM_ID =
                  T.TAKIM_ID;


            IF SQL%ROWCOUNT = 0 THEN

                INSERT INTO DE_BASKETBOL_PUAN_DURUMU (
                    LIG_ID,
                    TAKIM_ID,
                    OYNANAN_MAC,
                    GALIBIYET,
                    MAGLUBIYET,
                    ATILAN_SAYI,
                    YENILEN_SAYI,
                    IC_AVERAJ,
                    IC_PUAN,
                    TOPLAM_AVERAJ,
                    PUAN
                )
                VALUES (
                    P_LIG_ID,
                    T.TAKIM_ID,
                    V_O,
                    V_G,
                    V_M,
                    V_A,
                    V_Y,
                    0,
                    0,
                    V_A - V_Y,
                    V_PUAN
                );

            END IF;



        /* =================================================
           VOLEYBOL
           ================================================= */

        ELSIF V_FED = 3 THEN


            SELECT

                COUNT(*),

                NVL(SUM(
                    CASE
                        WHEN ATILAN = 3 THEN 1
                        ELSE 0
                    END
                ),0),

                NVL(SUM(
                    CASE
                        WHEN YENILEN = 3 THEN 1
                        ELSE 0
                    END
                ),0),

                NVL(SUM(ATILAN),0),

                NVL(SUM(YENILEN),0),

                NVL(SUM(
                    CASE

                        WHEN ATILAN = 3
                             AND YENILEN IN (0,1)
                            THEN 3

                        WHEN ATILAN = 3
                             AND YENILEN = 2
                            THEN 2

                        WHEN ATILAN = 2
                             AND YENILEN = 3
                            THEN 1

                        ELSE 0

                    END
                ),0)

            INTO
                V_O,
                V_G,
                V_M,
                V_A,
                V_Y,
                V_PUAN

            FROM (

                SELECT

                    TO_NUMBER(
                        REGEXP_SUBSTR(
                            MAC_SONUCU,
                            '^[0-9]+'
                        )
                    ) ATILAN,

                    TO_NUMBER(
                        REGEXP_SUBSTR(
                            MAC_SONUCU,
                            '[0-9]+$'
                        )
                    ) YENILEN

                FROM DE_FIKSTUR

                WHERE LIG_ID =
                      P_LIG_ID

                  AND EV_SAHIBI_TAKIM_ID =
                      T.TAKIM_ID

                  AND UPPER(TRIM(MAC_SONUCU))
                      <> 'OYNANMADI'


                UNION ALL


                SELECT

                    TO_NUMBER(
                        REGEXP_SUBSTR(
                            MAC_SONUCU,
                            '[0-9]+$'
                        )
                    ),

                    TO_NUMBER(
                        REGEXP_SUBSTR(
                            MAC_SONUCU,
                            '^[0-9]+'
                        )
                    )

                FROM DE_FIKSTUR

                WHERE LIG_ID =
                      P_LIG_ID

                  AND DEPLASMAN_TAKIM_ID =
                      T.TAKIM_ID

                  AND UPPER(TRIM(MAC_SONUCU))
                      <> 'OYNANMADI'

            );


            IF V_Y = 0 THEN
                V_SET_ORANI := V_A;
            ELSE
                V_SET_ORANI :=
                    ROUND(V_A / V_Y, 3);
            END IF;


            SELECT
                NVL(SUM(
                    CASE
                        WHEN SL.TAKIM_ID =
                             T.TAKIM_ID
                            THEN SL.SKOR_DEGERI
                        ELSE 0
                    END
                ),0),

                NVL(SUM(
                    CASE
                        WHEN SL.TAKIM_ID <>
                             T.TAKIM_ID
                            THEN SL.SKOR_DEGERI
                        ELSE 0
                    END
                ),0)

            INTO
                V_ALINAN_SAYI,
                V_VERILEN_SAYI

            FROM DE_SKOR_LOG SL

            JOIN DE_FIKSTUR F
                ON F.FIKSTUR_ID =
                   SL.FIKSTUR_ID

            WHERE F.LIG_ID =
                  P_LIG_ID

              AND SL.SKOR_TURU =
                  'SET_PUANI'

              AND (
                    F.EV_SAHIBI_TAKIM_ID =
                    T.TAKIM_ID

                    OR

                    F.DEPLASMAN_TAKIM_ID =
                    T.TAKIM_ID
                  );


            IF V_VERILEN_SAYI = 0 THEN
                V_SAYI_ORANI :=
                    V_ALINAN_SAYI;
            ELSE
                V_SAYI_ORANI :=
                    ROUND(
                        V_ALINAN_SAYI /
                        V_VERILEN_SAYI,
                        3
                    );
            END IF;


            UPDATE DE_VOLEYBOL_PUAN_DURUMU

            SET
                OYNANAN_MAC       = V_O,
                GALIBIYET         = V_G,
                MAGLUBIYET        = V_M,
                ALINAN_SET        = V_A,
                VERILEN_SET       = V_Y,
                SET_ORANI         = V_SET_ORANI,
                ALINAN_SAYI_PUANI = V_ALINAN_SAYI,
                VERILEN_SAYI_PUANI = V_VERILEN_SAYI,
                SAYI_PUANI_ORANI  = V_SAYI_ORANI,
                PUAN              = V_PUAN

            WHERE LIG_ID =
                  P_LIG_ID

              AND TAKIM_ID =
                  T.TAKIM_ID;


            IF SQL%ROWCOUNT = 0 THEN

                INSERT INTO DE_VOLEYBOL_PUAN_DURUMU (
                    LIG_ID,
                    TAKIM_ID,
                    OYNANAN_MAC,
                    GALIBIYET,
                    MAGLUBIYET,
                    ALINAN_SET,
                    VERILEN_SET,
                    SET_ORANI,
                    ALINAN_SAYI_PUANI,
                    VERILEN_SAYI_PUANI,
                    SAYI_PUANI_ORANI,
                    PUAN
                )
                VALUES (
                    P_LIG_ID,
                    T.TAKIM_ID,
                    V_O,
                    V_G,
                    V_M,
                    V_A,
                    V_Y,
                    V_SET_ORANI,
                    V_ALINAN_SAYI,
                    V_VERILEN_SAYI,
                    V_SAYI_ORANI,
                    V_PUAN
                );

            END IF;

        END IF;

    END LOOP;

END DE_PUAN_DURUMU_HESAPLA;
/
