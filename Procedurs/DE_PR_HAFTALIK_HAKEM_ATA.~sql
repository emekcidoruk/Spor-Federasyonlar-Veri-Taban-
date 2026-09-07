CREATE OR REPLACE PROCEDURE DE_HAFTALIK_HAKEM_ATA (
    P_HAFTA IN NUMBER
)
AS

    V_HAKEM_ID NUMBER;

    V_MEVCUT NUMBER;

    V_ONCEKI_MAC NUMBER;

    V_HAFTA_MAC NUMBER;

    V_EKLENEN NUMBER := 0;



    /* =====================================================
       TEK GOREV ICIN HAKEM ATA
       ===================================================== */

    PROCEDURE GOREV_ATA (

        P_FIKSTUR_ID    IN NUMBER,
        P_FEDERASYON_ID IN NUMBER,
        P_HAFTA_NO      IN NUMBER,
        P_GOREV         IN VARCHAR2,
        P_ADET          IN NUMBER

    )
    AS

    BEGIN

        SELECT COUNT(*)
        INTO V_MEVCUT

        FROM DE_FIKSTUR_HAKEM

        WHERE FIKSTUR_ID =
              P_FIKSTUR_ID

          AND UPPER(TRIM(HAKEM_GOREVI))
              = UPPER(TRIM(P_GOREV));


        IF V_MEVCUT >= P_ADET THEN
            RETURN;
        END IF;



        FOR I IN
            (V_MEVCUT + 1)..P_ADET
        LOOP


            BEGIN

                /* =========================================
                   ÖNCE KLASMANA UYGUN HAKEM
                   ========================================= */

                SELECT HAKEM_ID
                INTO V_HAKEM_ID

                FROM (

                    SELECT
                        H.HAKEM_ID,

                        (
                            SELECT COUNT(*)

                            FROM DE_FIKSTUR_HAKEM X

                            WHERE X.HAKEM_ID =
                                  H.HAKEM_ID
                        ) TOPLAM_ATAMA

                    FROM DE_HAKEMLER H

                    JOIN DE_HAKEM_KLASMAN K
                        ON K.KLASMAN_ID =
                           H.KLASMAN_ID

                    WHERE H.FEDERASYON_ID =
                          P_FEDERASYON_ID

                      AND H.HAKEM_AKTIFLIK = 1

                      AND H.HAKEM_ATANMA =
                          'ATANMADI'


                      /* Ayný hafta ikinci maç yok */

                      AND NOT EXISTS (

                            SELECT 1

                            FROM DE_FIKSTUR_HAKEM FH

                            JOIN DE_FIKSTUR F
                                ON F.FIKSTUR_ID =
                                   FH.FIKSTUR_ID

                            WHERE FH.HAKEM_ID =
                                  H.HAKEM_ID

                              AND F.HAFTA =
                                  P_HAFTA_NO
                      )


                      /* Ayný maçta tekrar yok */

                      AND NOT EXISTS (

                            SELECT 1

                            FROM DE_FIKSTUR_HAKEM FH

                            WHERE FH.FIKSTUR_ID =
                                  P_FIKSTUR_ID

                              AND FH.HAKEM_ID =
                                  H.HAKEM_ID
                      )


                      AND (

                          /* ================================
                             FUTBOL
                             ================================ */

                          (
                              P_FEDERASYON_ID = 1

                              AND (

                                  (
                                      P_GOREV =
                                      'YARDIMCI HAKEM'

                                      AND
                                      UPPER(K.KLASMAN_TURU)
                                      LIKE '%YARDIMCI%'

                                      AND
                                      UPPER(K.KLASMAN_TURU)
                                      NOT LIKE '%VIDEO%'
                                  )

                                  OR

                                  (
                                      P_GOREV IN (
                                          'VAR',
                                          'AVAR'
                                      )

                                      AND
                                      UPPER(K.KLASMAN_TURU)
                                      LIKE '%VIDEO%'
                                  )

                                  OR

                                  (
                                      P_GOREV =
                                      'ORTA HAKEM'

                                      AND
                                      UPPER(K.KLASMAN_TURU)
                                      LIKE '%HAKEM%'

                                      AND
                                      UPPER(K.KLASMAN_TURU)
                                      NOT LIKE '%YARDIMCI%'

                                      AND
                                      UPPER(K.KLASMAN_TURU)
                                      NOT LIKE '%VIDEO%'
                                  )

                                  OR

                                  (
                                      P_GOREV =
                                      'DORDUNCU HAKEM'

                                      AND
                                      UPPER(K.KLASMAN_TURU)
                                      NOT LIKE '%VIDEO%'
                                  )
                              )
                          )


                          /* ================================
                             BASKETBOL
                             ================================ */

                          OR

                          (
                              P_FEDERASYON_ID = 2

                              AND (

                                  P_GOREV =
                                  'YARDIMCI HAKEM'

                                  OR

                                  (
                                      P_GOREV =
                                      'BASHAKEM'

                                      AND SUBSTR(
                                          UPPER(
                                              TRIM(
                                                  K.KLASMAN_TURU
                                              )
                                          ),
                                          1,
                                          1
                                      ) = 'A'
                                  )
                              )
                          )


                          /* ================================
                             VOLEYBOL
                             ================================ */

                          OR

                          (
                              P_FEDERASYON_ID = 3

                              AND (

                                  P_GOREV IN (
                                      'IKINCI HAKEM',
                                      'CIZGI HAKEMI'
                                  )

                                  OR

                                  (
                                      P_GOREV =
                                      'BIRINCI HAKEM'

                                      AND SUBSTR(
                                          UPPER(
                                              TRIM(
                                                  K.KLASMAN_TURU
                                              )
                                          ),
                                          1,
                                          1
                                      ) = 'A'
                                  )
                              )
                          )

                      )

                    ORDER BY

                        TOPLAM_ATAMA,

                        DBMS_RANDOM.VALUE

                )

                WHERE ROWNUM = 1;



            EXCEPTION

                /* =========================================
                   UYGUN KLASMAN BULUNAMAZSA
                   AYNI FEDERASYONDAN UYGUN HAKEM
                   ========================================= */

                WHEN NO_DATA_FOUND THEN


                    BEGIN

                        SELECT HAKEM_ID
                        INTO V_HAKEM_ID

                        FROM (

                            SELECT
                                H.HAKEM_ID,

                                (
                                    SELECT COUNT(*)

                                    FROM DE_FIKSTUR_HAKEM X

                                    WHERE X.HAKEM_ID =
                                          H.HAKEM_ID
                                ) TOPLAM_ATAMA

                            FROM DE_HAKEMLER H

                            WHERE H.FEDERASYON_ID =
                                  P_FEDERASYON_ID

                              AND H.HAKEM_AKTIFLIK = 1

                              AND H.HAKEM_ATANMA =
                                  'ATANMADI'


                              AND NOT EXISTS (

                                  SELECT 1

                                  FROM DE_FIKSTUR_HAKEM FH

                                  JOIN DE_FIKSTUR F
                                    ON F.FIKSTUR_ID =
                                       FH.FIKSTUR_ID

                                  WHERE FH.HAKEM_ID =
                                        H.HAKEM_ID

                                    AND F.HAFTA =
                                        P_HAFTA_NO
                              )


                              AND NOT EXISTS (

                                  SELECT 1

                                  FROM DE_FIKSTUR_HAKEM FH

                                  WHERE FH.FIKSTUR_ID =
                                        P_FIKSTUR_ID

                                    AND FH.HAKEM_ID =
                                        H.HAKEM_ID
                              )

                            ORDER BY

                                TOPLAM_ATAMA,

                                DBMS_RANDOM.VALUE

                        )

                        WHERE ROWNUM = 1;


                    EXCEPTION

                        WHEN NO_DATA_FOUND THEN

                            RAISE_APPLICATION_ERROR(
                                -20100,

                                P_HAFTA_NO ||
                                '. hafta FIKSTUR_ID=' ||
                                P_FIKSTUR_ID ||
                                ' icin yeterli hakem bulunamadi.'
                            );

                    END;

            END;



            INSERT INTO DE_FIKSTUR_HAKEM (

                FIKSTUR_ID,
                HAKEM_ID,
                HAKEM_GOREVI

            )
            VALUES (

                P_FIKSTUR_ID,
                V_HAKEM_ID,
                P_GOREV

            );


            V_EKLENEN :=
                V_EKLENEN + 1;


        END LOOP;

    END GOREV_ATA;



BEGIN

    SAVEPOINT SP_HAKEM_ATA;


    IF P_HAFTA IS NULL
       OR P_HAFTA <= 0
    THEN

        RAISE_APPLICATION_ERROR(
            -20101,
            'Gecerli hafta giriniz.'
        );

    END IF;



    /* =====================================================
       ÖNCEKÝ HAFTA BÝTMEDEN YENÝ HAFTA HAKEMÝ ATANAMAZ
       ===================================================== */

    SELECT COUNT(*)
    INTO V_ONCEKI_MAC

    FROM DE_FIKSTUR

    WHERE HAFTA < P_HAFTA

      AND UPPER(TRIM(MAC_SONUCU))
          = 'OYNANMADI';


    IF V_ONCEKI_MAC > 0 THEN

        RAISE_APPLICATION_ERROR(
            -20102,
            'Onceki haftalarda bitmemis mac var. ' ||
            'Yeni haftaya hakem atanamaz.'
        );

    END IF;



    /* =====================================================
       STALE HAKEM DURUMLARINI TEMIZLE
       ===================================================== */

    UPDATE DE_HAKEMLER H

    SET
        HAKEM_ATANMA =
            'ATANMADI',

        ISLEM_TARIHI =
            SYSDATE

    WHERE H.HAKEM_ATANMA =
          'ATANDI'

      AND NOT EXISTS (

            SELECT 1

            FROM DE_FIKSTUR_HAKEM FH

            JOIN DE_FIKSTUR F
                ON F.FIKSTUR_ID =
                   FH.FIKSTUR_ID

            WHERE FH.HAKEM_ID =
                  H.HAKEM_ID

              AND UPPER(TRIM(F.MAC_SONUCU))
                  = 'OYNANMADI'
      );



    SELECT COUNT(*)
    INTO V_HAFTA_MAC

    FROM DE_FIKSTUR

    WHERE HAFTA = P_HAFTA

      AND UPPER(TRIM(MAC_SONUCU))
          = 'OYNANMADI';


    IF V_HAFTA_MAC = 0 THEN

        RAISE_APPLICATION_ERROR(
            -20103,
            P_HAFTA ||
            '. haftada oynanmamis mac yok.'
        );

    END IF;



    /* =====================================================
       HAFTANIN MACLARI
       ===================================================== */

    FOR F IN (

        SELECT
            FIKSTUR_ID,
            FEDERASYON_ID,
            HAFTA

        FROM DE_FIKSTUR

        WHERE HAFTA = P_HAFTA

          AND UPPER(TRIM(MAC_SONUCU))
              = 'OYNANMADI'

        ORDER BY
            FEDERASYON_ID,
            LIG_ID,
            MAC_TARIHI,
            FIKSTUR_ID

    )
    LOOP


        /* FUTBOL */

        IF F.FEDERASYON_ID = 1 THEN


            GOREV_ATA(
                F.FIKSTUR_ID,
                1,
                P_HAFTA,
                'ORTA HAKEM',
                1
            );


            GOREV_ATA(
                F.FIKSTUR_ID,
                1,
                P_HAFTA,
                'YARDIMCI HAKEM',
                2
            );


            GOREV_ATA(
                F.FIKSTUR_ID,
                1,
                P_HAFTA,
                'DORDUNCU HAKEM',
                1
            );


            GOREV_ATA(
                F.FIKSTUR_ID,
                1,
                P_HAFTA,
                'VAR',
                1
            );


            GOREV_ATA(
                F.FIKSTUR_ID,
                1,
                P_HAFTA,
                'AVAR',
                1
            );



        /* BASKETBOL */

        ELSIF F.FEDERASYON_ID = 2 THEN


            GOREV_ATA(
                F.FIKSTUR_ID,
                2,
                P_HAFTA,
                'BASHAKEM',
                1
            );


            GOREV_ATA(
                F.FIKSTUR_ID,
                2,
                P_HAFTA,
                'YARDIMCI HAKEM',
                2
            );



        /* VOLEYBOL */

        ELSIF F.FEDERASYON_ID = 3 THEN


            GOREV_ATA(
                F.FIKSTUR_ID,
                3,
                P_HAFTA,
                'BIRINCI HAKEM',
                1
            );


            GOREV_ATA(
                F.FIKSTUR_ID,
                3,
                P_HAFTA,
                'IKINCI HAKEM',
                1
            );


            GOREV_ATA(
                F.FIKSTUR_ID,
                3,
                P_HAFTA,
                'CIZGI HAKEMI',
                2
            );


        END IF;


    END LOOP;


    DBMS_OUTPUT.PUT_LINE(
        P_HAFTA ||
        '. hafta hakem atamasi tamamlandi.'
    );


    DBMS_OUTPUT.PUT_LINE(
        'Eklenen atama: ' ||
        V_EKLENEN
    );


EXCEPTION

    WHEN OTHERS THEN

        ROLLBACK TO SP_HAKEM_ATA;

        RAISE;

END DE_HAFTALIK_HAKEM_ATA;
/
