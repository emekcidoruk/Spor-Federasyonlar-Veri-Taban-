DECLARE

    TYPE T_LISTE IS TABLE OF VARCHAR2(100) INDEX BY PLS_INTEGER;

    V_ERKEK_ISIMLER  T_LISTE;
    V_KADIN_ISIMLER  T_LISTE;
    V_SOYISIMLER     T_LISTE;

    V_FEDERASYON_ID  NUMBER;
    V_KLASMAN_ID     NUMBER;

    V_ISIM           VARCHAR2(50);
    V_SOYISIM        VARCHAR2(50);
    V_AD_SOYAD       VARCHAR2(150);

    V_AKTIFLIK       NUMBER;

    /* 1 = Erkek, 2 = Kadýn */
    V_CINSIYET       NUMBER;

BEGIN

    /* =====================================================
       ERKEK ISIMLER
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
    V_ERKEK_ISIMLER(31) := 'Alper';
    V_ERKEK_ISIMLER(32) := 'Gokhan';
    V_ERKEK_ISIMLER(33) := 'Hakan';
    V_ERKEK_ISIMLER(34) := 'Sinan';
    V_ERKEK_ISIMLER(35) := 'Selim';
    V_ERKEK_ISIMLER(36) := 'Yigit';
    V_ERKEK_ISIMLER(37) := 'Bora';
    V_ERKEK_ISIMLER(38) := 'Ozan';
    V_ERKEK_ISIMLER(39) := 'Cagri';
    V_ERKEK_ISIMLER(40) := 'Volkan';


    /* =====================================================
       KADIN ISIMLER
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
    V_KADIN_ISIMLER(26) := 'Eylul';
    V_KADIN_ISIMLER(27) := 'Nisa';
    V_KADIN_ISIMLER(28) := 'Derin';
    V_KADIN_ISIMLER(29) := 'Ada';
    V_KADIN_ISIMLER(30) := 'Alara';
    V_KADIN_ISIMLER(31) := 'Miray';
    V_KADIN_ISIMLER(32) := 'Ezgi';
    V_KADIN_ISIMLER(33) := 'Beyza';
    V_KADIN_ISIMLER(34) := 'Gamze';
    V_KADIN_ISIMLER(35) := 'Hazal';
    V_KADIN_ISIMLER(36) := 'Dilara';
    V_KADIN_ISIMLER(37) := 'Ipek';
    V_KADIN_ISIMLER(38) := 'Aleyna';
    V_KADIN_ISIMLER(39) := 'Nehir';
    V_KADIN_ISIMLER(40) := 'Cansu';


    /* =====================================================
       SOYISIMLER
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
       500 HAKEM
       ===================================================== */

    FOR I IN 1..500 LOOP


        /* =================================================
           FEDERASYON

           200 Futbol
           150 Basketbol
           150 Voleybol
           ================================================= */

        IF I <= 200 THEN

            V_FEDERASYON_ID := 1;

        ELSIF I <= 350 THEN

            V_FEDERASYON_ID := 2;

        ELSE

            V_FEDERASYON_ID := 3;

        END IF;


        /* =================================================
           CINSIYET SEC

           %70 erkek
           %30 kadin
           ================================================= */

        IF DBMS_RANDOM.VALUE(0, 100) < 30 THEN

            V_CINSIYET := 2;

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

            V_CINSIYET := 1;

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


        /* =================================================
           SOYISIM
           ================================================= */

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
            V_ISIM || ' ' ||
            V_SOYISIM || ' ' ||
            I;


        /* =================================================
           KLASMAN SECIMI
           ================================================= */


        /* -------------------------------------------------
           ERKEK HAKEM

           "KADIN" ifadesi bulunan klasmanlari ALMA.
           ------------------------------------------------- */

        IF V_CINSIYET = 1 THEN

            SELECT KLASMAN_ID
            INTO V_KLASMAN_ID
            FROM (
                SELECT K.KLASMAN_ID
                FROM DE_HAKEM_KLASMAN K
                WHERE K.FEDERASYON_ID = V_FEDERASYON_ID
                  AND UPPER(K.KLASMAN_TURU) NOT LIKE '%KADIN%'
                ORDER BY DBMS_RANDOM.VALUE
            )
            WHERE ROWNUM = 1;


        /* -------------------------------------------------
           KADIN HAKEM

           Kadin hakem genel klasmanlarda da olabilir.

           TFF'deki:
           - Kadin Bolgesel Hakemi
           - Kadin Bolgesel Yardimci Hakemi

           klasmanlari da secilebilir.
           ------------------------------------------------- */

        ELSE

            SELECT KLASMAN_ID
            INTO V_KLASMAN_ID
            FROM (
                SELECT K.KLASMAN_ID
                FROM DE_HAKEM_KLASMAN K
                WHERE K.FEDERASYON_ID = V_FEDERASYON_ID
                ORDER BY DBMS_RANDOM.VALUE
            )
            WHERE ROWNUM = 1;

        END IF;


        /* =================================================
           AKTIFLIK

           %90 aktif
           %10 pasif
           ================================================= */

        IF DBMS_RANDOM.VALUE(0, 100) < 90 THEN
            V_AKTIFLIK := 1;
        ELSE
            V_AKTIFLIK := 0;
        END IF;


        /* =================================================
           INSERT
           ================================================= */

        INSERT INTO DE_HAKEMLER (
            FEDERASYON_ID,
            HAKEM_ADI_SOYADI,
            KLASMAN_ID,
            HAKEM_AKTIFLIK,
            HAKEM_ATANMA
        )
        VALUES (
            V_FEDERASYON_ID,
            V_AD_SOYAD,
            V_KLASMAN_ID,
            V_AKTIFLIK,
            'ATANMADI'
        );


    END LOOP;


    COMMIT;


    DBMS_OUTPUT.PUT_LINE(
        '500 hakem basariyla olusturuldu.'
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
