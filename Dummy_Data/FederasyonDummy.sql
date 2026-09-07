BEGIN

    /* =====================================================
       1 - TURKIYE FUTBOL FEDERASYONU
       ===================================================== */

    INSERT INTO DE_FEDERASYONLAR (
        FEDERASYON_ADI,
        FEDERASYON_BASKANI,
        FEDERASYON_BASKAN_YARDIMCISI,
        FEDERASYON_ADRESI,
        FEDERASYON_KURULUS_TARIHI,
        FEDERASYON_MAIL_ADRESI,
        FEDERASYON_WEB_SITESI
    )
    VALUES (
        'Türkiye Futbol Federasyonu',
        'Ýbrahim Ethem Hacýosmanoðlu',
        'Mecnun Otyakmaz',
        'Hasan Doðan Milli Takýmlar Kamp ve Eðitim Tesisleri, Çayaðzý Köyü, Riva / Beykoz / Ýstanbul',
        TO_DATE('23.04.1923', 'DD.MM.YYYY'),
        'iletisim@tff.org',
        'www.tff.org'
    );


    /* =====================================================
       2 - TURKIYE BASKETBOL FEDERASYONU
       ===================================================== */

    INSERT INTO DE_FEDERASYONLAR (
        FEDERASYON_ADI,
        FEDERASYON_BASKANI,
        FEDERASYON_BASKAN_YARDIMCISI,
        FEDERASYON_ADRESI,
        FEDERASYON_KURULUS_TARIHI,
        FEDERASYON_MAIL_ADRESI,
        FEDERASYON_WEB_SITESI
    )
    VALUES (
        'Türkiye Basketbol Federasyonu',
        'Hidayet Türkoðlu',
        'Harun Erdenay',
        'Kazlýçeþme Mahallesi 10. Yýl Caddesi No:2/1, Zeytinburnu / Ýstanbul',
        TO_DATE('01.03.1959', 'DD.MM.YYYY'),
        'tbf@tbf.org.tr',
        'www.tbf.org.tr'
    );


    /* =====================================================
       3 - TURKIYE VOLEYBOL FEDERASYONU
       ===================================================== */

    INSERT INTO DE_FEDERASYONLAR (
        FEDERASYON_ADI,
        FEDERASYON_BASKANI,
        FEDERASYON_BASKAN_YARDIMCISI,
        FEDERASYON_ADRESI,
        FEDERASYON_KURULUS_TARIHI,
        FEDERASYON_MAIL_ADRESI,
        FEDERASYON_WEB_SITESI
    )
    VALUES (
        'Türkiye Voleybol Federasyonu',
        'Mehmet Akif Üstündað',
        'Alper Sedat Aslandaþ',
        'Emniyet Mahallesi Milas Sokak No:9/A, Yenimahalle / Ankara',
        TO_DATE('28.10.1958', 'DD.MM.YYYY'),
        'info@tvf.org.tr',
        'www.tvf.org.tr'
    );


    COMMIT;

    DBMS_OUTPUT.PUT_LINE(
        'Federasyon dummy datalari basariyla eklendi.'
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
