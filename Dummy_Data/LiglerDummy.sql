BEGIN

    /* =====================================================
       1 - TRENDYOL SUPER LIG
       FEDERASYON: FUTBOL
       ===================================================== */

    INSERT INTO DE_LIGLER (
        FEDERASYON_ID,
        LIG_ADI,
        LIG_KAPASITE
    )
    VALUES (
        1,
        'Trendyol Süper Lig',
        18
    );


    /* =====================================================
       2 - TRENDYOL 1. LIG
       FEDERASYON: FUTBOL
       ===================================================== */

    INSERT INTO DE_LIGLER (
        FEDERASYON_ID,
        LIG_ADI,
        LIG_KAPASITE
    )
    VALUES (
        1,
        'Trendyol 1. Lig',
        20
    );


    /* =====================================================
       3 - BASKETBOL SUPER LIGI
       FEDERASYON: BASKETBOL
       ===================================================== */

    INSERT INTO DE_LIGLER (
        FEDERASYON_ID,
        LIG_ADI,
        LIG_KAPASITE
    )
    VALUES (
        2,
        'Türkiye Sigorta Basketbol Süper Ligi',
        16
    );


    /* =====================================================
       4 - TURKIYE BASKETBOL LIGI
       FEDERASYON: BASKETBOL
       ===================================================== */

    INSERT INTO DE_LIGLER (
        FEDERASYON_ID,
        LIG_ADI,
        LIG_KAPASITE
    )
    VALUES (
        2,
        'Türkiye Sigorta Türkiye Basketbol Ligi',
        17
    );


    /* =====================================================
       5 - VODAFONE SULTANLAR LIGI
       FEDERASYON: VOLEYBOL
       ===================================================== */

    INSERT INTO DE_LIGLER (
        FEDERASYON_ID,
        LIG_ADI,
        LIG_KAPASITE
    )
    VALUES (
        3,
        'Vodafone Sultanlar Ligi',
        14
    );


    /* =====================================================
       6 - SMS GRUP EFELER LIGI
       FEDERASYON: VOLEYBOL
       ===================================================== */

    INSERT INTO DE_LIGLER (
        FEDERASYON_ID,
        LIG_ADI,
        LIG_KAPASITE
    )
    VALUES (
        3,
        'SMS Grup Efeler Ligi',
        14
    );


    COMMIT;

    DBMS_OUTPUT.PUT_LINE(
        '6 adet lig verisi basariyla eklendi.'
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
