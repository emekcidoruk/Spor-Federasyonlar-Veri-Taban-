DECLARE

    /* =====================================================
       LISTE TIPI
       ===================================================== */

    TYPE T_LISTE IS TABLE OF VARCHAR2(100) INDEX BY PLS_INTEGER;

    V_ERKEK_ISIMLER T_LISTE;
    V_KADIN_ISIMLER T_LISTE;
    V_SOYISIMLER    T_LISTE;
    V_SEHIRLER      T_LISTE;


    /* =====================================================
       DEGISKENLER
       ===================================================== */

    V_ISIM           VARCHAR2(50);
    V_SOYISIM        VARCHAR2(50);
    V_AD_SOYAD       VARCHAR2(150);
    V_DOGUM_YERI     VARCHAR2(100);
    V_MEVKI          VARCHAR2(100);

    V_DOGUM_TARIHI   DATE;
    V_LISANS_TARIHI  DATE;
    V_SOZLESME_BAS   DATE;
    V_SOZLESME_BITIS DATE;

    V_LISANS_NO      NUMBER;
    V_SON_LISANS_NO  NUMBER;

    V_TAKIM_SAYISI   NUMBER;
    V_OYUNCU_SAYISI  NUMBER := 0;
    V_SIRA           NUMBER := 0;
    V_TAKIM_OYUNCU_SAYISI NUMBER;


BEGIN

    /* =====================================================
       ERKEK ISIMLER - 40
       ===================================================== */

    V_ERKEK_ISIMLER(1)  := 'Ahmet';
    V_ERKEK_ISIMLER(2)  := 'Mehmet';
    V_ERKEK_ISIMLER(3)  := 'Mustafa';
    V_ERKEK_ISIMLER(4)  := 'Ali';
    V_ERKEK_ISIMLER(5)  := 'Emre';
    V_ERKEK_ISIMLER(6)  := 'Burak';
    V_ERKEK_ISIMLER(7)  := 'Mert';
    V_ERKEK_ISIMLER(8)  := 'Kerem';
    V_ERKEK_ISIMLER(9)  := 'Enes';
    V_ERKEK_ISIMLER(10) := 'Can';

    V_ERKEK_ISIMLER(11) := 'Arda';
    V_ERKEK_ISIMLER(12) := 'Emir';
    V_ERKEK_ISIMLER(13) := 'Kaan';
    V_ERKEK_ISIMLER(14) := 'Berk';
    V_ERKEK_ISIMLER(15) := 'Eren';
    V_ERKEK_ISIMLER(16) := 'Oguz';
    V_ERKEK_ISIMLER(17) := 'Batuhan';
    V_ERKEK_ISIMLER(18) := 'Onur';
    V_ERKEK_ISIMLER(19) := 'Furkan';
    V_ERKEK_ISIMLER(20) := 'Yusuf';

    V_ERKEK_ISIMLER(21) := 'Omer';
    V_ERKEK_ISIMLER(22) := 'Ismail';
    V_ERKEK_ISIMLER(23) := 'Hasan';
    V_ERKEK_ISIMLER(24) := 'Huseyin';
    V_ERKEK_ISIMLER(25) := 'Tolga';
    V_ERKEK_ISIMLER(26) := 'Serkan';
    V_ERKEK_ISIMLER(27) := 'Umut';
    V_ERKEK_ISIMLER(28) := 'Baris';
    V_ERKEK_ISIMLER(29) := 'Cem';
    V_ERKEK_ISIMLER(30) := 'Deniz';

    V_ERKEK_ISIMLER(31) := 'Doruk';
    V_ERKEK_ISIMLER(32) := 'Alper';
    V_ERKEK_ISIMLER(33) := 'Gokhan';
    V_ERKEK_ISIMLER(34) := 'Hakan';
    V_ERKEK_ISIMLER(35) := 'Sinan';
    V_ERKEK_ISIMLER(36) := 'Selim';
    V_ERKEK_ISIMLER(37) := 'Yigit';
    V_ERKEK_ISIMLER(38) := 'Bora';
    V_ERKEK_ISIMLER(39) := 'Ozan';
    V_ERKEK_ISIMLER(40) := 'Cagri';


    /* =====================================================
       KADIN ISIMLER - 40
       SADECE LIG_ID = 5
       ===================================================== */

    V_KADIN_ISIMLER(1)  := 'Ayse';
    V_KADIN_ISIMLER(2)  := 'Elif';
    V_KADIN_ISIMLER(3)  := 'Zeynep';
    V_KADIN_ISIMLER(4)  := 'Ece';
    V_KADIN_ISIMLER(5)  := 'Irem';
    V_KADIN_ISIMLER(6)  := 'Seda';
    V_KADIN_ISIMLER(7)  := 'Ceren';
    V_KADIN_ISIMLER(8)  := 'Melis';
    V_KADIN_ISIMLER(9)  := 'Selin';
    V_KADIN_ISIMLER(10) := 'Derya';

    V_KADIN_ISIMLER(11) := 'Buse';
    V_KADIN_ISIMLER(12) := 'Esra';
    V_KADIN_ISIMLER(13) := 'Sude';
    V_KADIN_ISIMLER(14) := 'Naz';
    V_KADIN_ISIMLER(15) := 'Defne';
    V_KADIN_ISIMLER(16) := 'Ilayda';
    V_KADIN_ISIMLER(17) := 'Yagmur';
    V_KADIN_ISIMLER(18) := 'Damla';
    V_KADIN_ISIMLER(19) := 'Gizem';
    V_KADIN_ISIMLER(20) := 'Merve';

    V_KADIN_ISIMLER(21) := 'Asli';
    V_KADIN_ISIMLER(22) := 'Pelin';
    V_KADIN_ISIMLER(23) := 'Tugce';
    V_KADIN_ISIMLER(24) := 'Basak';
    V_KADIN_ISIMLER(25) := 'Sena';
    V_KADIN_ISIMLER(26) := 'Berfin';
    V_KADIN_ISIMLER(27) := 'Eylul';
    V_KADIN_ISIMLER(28) := 'Nisa';
    V_KADIN_ISIMLER(29) := 'Derin';
    V_KADIN_ISIMLER(30) := 'Ada';

    V_KADIN_ISIMLER(31) := 'Alara';
    V_KADIN_ISIMLER(32) := 'Miray';
    V_KADIN_ISIMLER(33) := 'Ezgi';
    V_KADIN_ISIMLER(34) := 'Beyza';
    V_KADIN_ISIMLER(35) := 'Gamze';
    V_KADIN_ISIMLER(36) := 'Hazal';
    V_KADIN_ISIMLER(37) := 'Dilara';
    V_KADIN_ISIMLER(38) := 'Ipek';
    V_KADIN_ISIMLER(39) := 'Aleyna';
    V_KADIN_ISIMLER(40) := 'Nehir';


    /* =====================================================
       SOYISIMLER - 60
       ===================================================== */

    V_SOYISIMLER(1)  := 'Yilmaz';
    V_SOYISIMLER(2)  := 'Kaya';
    V_SOYISIMLER(3)  := 'Demir';
    V_SOYISIMLER(4)  := 'Celik';
    V_SOYISIMLER(5)  := 'Sahin';
    V_SOYISIMLER(6)  := 'Yildiz';
    V_SOYISIMLER(7)  := 'Yildirim';
    V_SOYISIMLER(8)  := 'Ozturk';
    V_SOYISIMLER(9)  := 'Aydin';
    V_SOYISIMLER(10) := 'Ozdemir';

    V_SOYISIMLER(11) := 'Arslan';
    V_SOYISIMLER(12) := 'Dogan';
    V_SOYISIMLER(13) := 'Kilic';
    V_SOYISIMLER(14) := 'Aslan';
    V_SOYISIMLER(15) := 'Cetin';
    V_SOYISIMLER(16) := 'Kurt';
    V_SOYISIMLER(17) := 'Koc';
    V_SOYISIMLER(18) := 'Ozkan';
    V_SOYISIMLER(19) := 'Simsek';
    V_SOYISIMLER(20) := 'Polat';

    V_SOYISIMLER(21) := 'Korkmaz';
    V_SOYISIMLER(22) := 'Ozcan';
    V_SOYISIMLER(23) := 'Aksoy';
    V_SOYISIMLER(24) := 'Karaca';
    V_SOYISIMLER(25) := 'Tekin';
    V_SOYISIMLER(26) := 'Eren';
    V_SOYISIMLER(27) := 'Acar';
    V_SOYISIMLER(28) := 'Gunes';
    V_SOYISIMLER(29) := 'Bozkurt';
    V_SOYISIMLER(30) := 'Bulut';

    V_SOYISIMLER(31) := 'Kaplan';
    V_SOYISIMLER(32) := 'Keskin';
    V_SOYISIMLER(33) := 'Avci';
    V_SOYISIMLER(34) := 'Tas';
    V_SOYISIMLER(35) := 'Turan';
    V_SOYISIMLER(36) := 'Guler';
    V_SOYISIMLER(37) := 'Cakir';
    V_SOYISIMLER(38) := 'Akin';
    V_SOYISIMLER(39) := 'Ucar';
    V_SOYISIMLER(40) := 'Erdogan';

    V_SOYISIMLER(41) := 'Kara';
    V_SOYISIMLER(42) := 'Isik';
    V_SOYISIMLER(43) := 'Ozer';
    V_SOYISIMLER(44) := 'Duman';
    V_SOYISIMLER(45) := 'Sari';
    V_SOYISIMLER(46) := 'Yalcin';
    V_SOYISIMLER(47) := 'Erdem';
    V_SOYISIMLER(48) := 'Sezer';
    V_SOYISIMLER(49) := 'Kose';
    V_SOYISIMLER(50) := 'Altun';

    V_SOYISIMLER(51) := 'Kocaman';
    V_SOYISIMLER(52) := 'Bayrak';
    V_SOYISIMLER(53) := 'Turkmen';
    V_SOYISIMLER(54) := 'Karaman';
    V_SOYISIMLER(55) := 'Gunduz';
    V_SOYISIMLER(56) := 'Aydogan';
    V_SOYISIMLER(57) := 'Basar';
    V_SOYISIMLER(58) := 'Onal';
    V_SOYISIMLER(59) := 'Kalkan';
    V_SOYISIMLER(60) := 'Dinc';


    /* =====================================================
       SEHIRLER
       ===================================================== */

    V_SEHIRLER(1)  := 'Istanbul';
    V_SEHIRLER(2)  := 'Ankara';
    V_SEHIRLER(3)  := 'Izmir';
    V_SEHIRLER(4)  := 'Bursa';
    V_SEHIRLER(5)  := 'Antalya';
    V_SEHIRLER(6)  := 'Adana';
    V_SEHIRLER(7)  := 'Konya';
    V_SEHIRLER(8)  := 'Samsun';
    V_SEHIRLER(9)  := 'Trabzon';
    V_SEHIRLER(10) := 'Elazig';

    V_SEHIRLER(11) := 'Kayseri';
    V_SEHIRLER(12) := 'Gaziantep';
    V_SEHIRLER(13) := 'Eskisehir';
    V_SEHIRLER(14) := 'Mersin';
    V_SEHIRLER(15) := 'Diyarbakir';


    /* =====================================================
       TAKIM SAYISI KONTROLU
       ===================================================== */

    SELECT COUNT(*)
    INTO V_TAKIM_SAYISI
    FROM DE_TAKIMLAR;


    IF V_TAKIM_SAYISI <> 99 THEN

        RAISE_APPLICATION_ERROR(
            -20001,
            'DE_TAKIMLAR tablosunda 99 takim olmasi gerekiyor. Mevcut takim sayisi: '
            || V_TAKIM_SAYISI
        );

    END IF;


    /* =====================================================
       LISANS NUMARASI

       Tablo bossa 100001'den baslar.
       Veri varsa mevcut en buyuk numaradan devam eder.
       ===================================================== */

    SELECT NVL(MAX(OYUNCU_LISANS_NO), 100000)
    INTO V_SON_LISANS_NO
    FROM DE_OYUNCULAR;


    /* =====================================================
       TAKIMLARI ID SIRASINA GORE GEZ

       1-18  -> LIG 1
       19-38 -> LIG 2
       39-54 -> LIG 3
       55-71 -> LIG 4
       72-85 -> LIG 5
       86-99 -> LIG 6
       ===================================================== */

    FOR T IN (

        SELECT
            TAKIM_ID,
            TAKIM_ADI,
            LIG_ID
        FROM DE_TAKIMLAR
        ORDER BY TAKIM_ID

    )
    LOOP

        V_SIRA := V_SIRA + 1;


        /* =================================================
           2014 / 99 DAGILIMI

           ILK 34 TAKIM -> 21 OYUNCU
           KALAN 65     -> 20 OYUNCU

           34 * 21 = 714
           65 * 20 = 1300
           TOPLAM = 2014
           ================================================= */

        IF V_SIRA <= 34 THEN

            V_TAKIM_OYUNCU_SAYISI := 21;

        ELSE

            V_TAKIM_OYUNCU_SAYISI := 20;

        END IF;


        /* =================================================
           TAKIM ICIN OYUNCULARI URET
           ================================================= */

        FOR J IN 1..V_TAKIM_OYUNCU_SAYISI LOOP

            V_OYUNCU_SAYISI := V_OYUNCU_SAYISI + 1;


            /* =============================================
               ISIM

               LIG 5 = KADIN VOLEYBOL
               ============================================= */

            IF T.LIG_ID = 5 THEN

                V_ISIM :=
                    V_KADIN_ISIMLER(
                        TRUNC(
                            DBMS_RANDOM.VALUE(
                                1,
                                V_KADIN_ISIMLER.COUNT + 1
                            )
                        )
                    );

            ELSE

                V_ISIM :=
                    V_ERKEK_ISIMLER(
                        TRUNC(
                            DBMS_RANDOM.VALUE(
                                1,
                                V_ERKEK_ISIMLER.COUNT + 1
                            )
                        )
                    );

            END IF;


            /* =============================================
               SOYISIM
               ============================================= */

            V_SOYISIM :=
                V_SOYISIMLER(
                    TRUNC(
                        DBMS_RANDOM.VALUE(
                            1,
                            V_SOYISIMLER.COUNT + 1
                        )
                    )
                );


            V_AD_SOYAD :=
                V_ISIM || ' ' || V_SOYISIM;


            /* =============================================
               DOGUM YERI
               ============================================= */

            V_DOGUM_YERI :=
                V_SEHIRLER(
                    TRUNC(
                        DBMS_RANDOM.VALUE(
                            1,
                            V_SEHIRLER.COUNT + 1
                        )
                    )
                );


            /* =============================================
               DOGUM TARIHI
               18 - 35 YAS
               ============================================= */

            V_DOGUM_TARIHI :=
                ADD_MONTHS(
                    TRUNC(SYSDATE),
                    -TRUNC(
                        DBMS_RANDOM.VALUE(
                            18 * 12,
                            36 * 12
                        )
                    )
                )
                - TRUNC(DBMS_RANDOM.VALUE(0, 28));


            /* =============================================
               LISANS VERILIS TARIHI

               15 - 18 YAS ARASI
               ============================================= */

            V_LISANS_TARIHI :=
                ADD_MONTHS(
                    V_DOGUM_TARIHI,
                    TRUNC(
                        DBMS_RANDOM.VALUE(
                            15 * 12,
                            18 * 12
                        )
                    )
                );


            /* =============================================
               SOZLESME BASLANGICI
               SON 3 YIL ICERISINDE
               ============================================= */

            V_SOZLESME_BAS :=
                TRUNC(SYSDATE)
                - TRUNC(
                    DBMS_RANDOM.VALUE(
                        0,
                        1095
                    )
                );


            /* Lisans tarihinden once sozlesme olmasin */

            IF V_SOZLESME_BAS < V_LISANS_TARIHI THEN

                V_SOZLESME_BAS :=
                    V_LISANS_TARIHI;

            END IF;


            /* =============================================
               SOZLESME BITISI
               1 - 5 YIL SONRA
               ============================================= */

            V_SOZLESME_BITIS :=
                ADD_MONTHS(
                    V_SOZLESME_BAS,
                    TRUNC(
                        DBMS_RANDOM.VALUE(
                            12,
                            61
                        )
                    )
                );


            /* =============================================
               MEVKI
               ============================================= */

            IF T.LIG_ID IN (1, 2) THEN

                /* =========================
                   FUTBOL
                   ========================= */

                CASE TRUNC(DBMS_RANDOM.VALUE(1, 6))

                    WHEN 1 THEN
                        V_MEVKI := 'Kaleci';

                    WHEN 2 THEN
                        V_MEVKI := 'Defans';

                    WHEN 3 THEN
                        V_MEVKI := 'Orta Saha';

                    WHEN 4 THEN
                        V_MEVKI := 'Forvet';

                    ELSE
                        V_MEVKI := 'Kanat';

                END CASE;


            ELSIF T.LIG_ID IN (3, 4) THEN

                /* =========================
                   BASKETBOL
                   ========================= */

                CASE TRUNC(DBMS_RANDOM.VALUE(1, 6))

                    WHEN 1 THEN
                        V_MEVKI := 'Oyun Kurucu';

                    WHEN 2 THEN
                        V_MEVKI := 'Sutor Gard';

                    WHEN 3 THEN
                        V_MEVKI := 'Kisa Forvet';

                    WHEN 4 THEN
                        V_MEVKI := 'Uzun Forvet';

                    ELSE
                        V_MEVKI := 'Pivot';

                END CASE;


            ELSIF T.LIG_ID IN (5, 6) THEN

                /* =========================
                   VOLEYBOL
                   ========================= */

                CASE TRUNC(DBMS_RANDOM.VALUE(1, 6))

                    WHEN 1 THEN
                        V_MEVKI := 'Pasor';

                    WHEN 2 THEN
                        V_MEVKI := 'Smacor';

                    WHEN 3 THEN
                        V_MEVKI := 'Orta Oyuncu';

                    WHEN 4 THEN
                        V_MEVKI := 'Pasor Caprazi';

                    ELSE
                        V_MEVKI := 'Libero';

                END CASE;

            END IF;


            /* =============================================
               BENZERSIZ LISANS NUMARASI
               ============================================= */

            V_LISANS_NO :=
                V_SON_LISANS_NO + V_OYUNCU_SAYISI;


            /* =============================================
               INSERT
               ============================================= */

            INSERT INTO DE_OYUNCULAR (
                OYUNCU_LISANS_NO,
                OYUNCU_ADI_SOYADI,
                OYUNCU_DOGUM_YERI,
                OYUNCU_DOGUM_TARIHI,
                TAKIM_ID,
                OYUNCU_SOZLESME_BAS,
                OYUNCU_SOZLESME_BITIS,
                OYUNCU_LISANS_VERILIS_TARIHI,
                OYUNCU_MEVKI
            )
            VALUES (
                V_LISANS_NO,
                V_AD_SOYAD,
                V_DOGUM_YERI,
                V_DOGUM_TARIHI,
                T.TAKIM_ID,
                V_SOZLESME_BAS,
                V_SOZLESME_BITIS,
                V_LISANS_TARIHI,
                V_MEVKI
            );


        END LOOP;

    END LOOP;


    /* =====================================================
       SON KONTROL
       ===================================================== */

    IF V_OYUNCU_SAYISI <> 2014 THEN

        ROLLBACK;

        RAISE_APPLICATION_ERROR(
            -20002,
            'Oyuncu sayisi 2014 olmadi. Uretilen: '
            || V_OYUNCU_SAYISI
        );

    END IF;


    COMMIT;


    DBMS_OUTPUT.PUT_LINE(
        '2014 adet oyuncu basariyla olusturuldu.'
    );


EXCEPTION

    WHEN OTHERS THEN

        ROLLBACK;

        DBMS_OUTPUT.PUT_LINE(
            'HATA: ' || SQLERRM
        );

        RAISE;

END;
/
