CREATE OR REPLACE VIEW DE_VW_FIKSTUR_MACLARI AS
SELECT
    /* =====================================================
       FIKSTUR
       ===================================================== */
    F.FIKSTUR_ID,

    /* =====================================================
       FEDERASYON
       ===================================================== */
    F.FEDERASYON_ID,
    FED.FEDERASYON_ADI,

    /* =====================================================
       LIG
       ===================================================== */
    F.LIG_ID,
    L.LIG_ADI,

    /* =====================================================
       HAFTA
       ===================================================== */
    F.HAFTA,

    /* =====================================================
       EV SAHIBI
       ===================================================== */
    F.EV_SAHIBI_TAKIM_ID,
    EV.TAKIM_ADI AS EV_SAHIBI_TAKIM_ADI,

    /* =====================================================
       DEPLASMAN
       ===================================================== */
    F.DEPLASMAN_TAKIM_ID,
    DEP.TAKIM_ADI AS DEPLASMAN_TAKIM_ADI,

    /* =====================================================
       MAC TARIHI
       ===================================================== */
    F.MAC_TARIHI,

    /* =====================================================
       MUSABAKA ALANI
       ===================================================== */
    F.MUSABAKA_ALANI_ID,
    M.MUSABAKA_ALANI_ADI,
    M.MUSABAKA_ALANI_ADRESI,
    M.MUSABAKA_ALANI_SEHIR,
    M.MUSABAKA_ALANI_KAPASITE,
    M.ZEMIN_TURU,

    /* =====================================================
       ORTAK MUSABAKA ALANI
       ===================================================== */
    O.ORTAK_GRUP_NO,

    /* =====================================================
       MAC SONUCU
       ===================================================== */
    F.MAC_SONUCU,

    /* =====================================================
       ISLEM TARIHI
       ===================================================== */
    F.ISLEM_TARIHI

FROM DE_FIKSTUR F

/* FEDERASYON */
JOIN DE_FEDERASYONLAR FED
    ON FED.FEDERASYON_ID = F.FEDERASYON_ID

/* LIG */
JOIN DE_LIGLER L
    ON L.LIG_ID = F.LIG_ID

/* EV SAHIBI */
JOIN DE_TAKIMLAR EV
    ON EV.TAKIM_ID = F.EV_SAHIBI_TAKIM_ID

/* DEPLASMAN */
JOIN DE_TAKIMLAR DEP
    ON DEP.TAKIM_ID = F.DEPLASMAN_TAKIM_ID

/* MUSABAKA ALANI */
JOIN DE_MUSABAKA_ALANI M
    ON M.MUSABAKA_ALANI_ID = F.MUSABAKA_ALANI_ID

/* ORTAK MUSABAKA ALANI */
LEFT JOIN (
    SELECT
        MUSABAKA_ALANI_ID,
        MIN(ORTAK_GRUP_NO) AS ORTAK_GRUP_NO
    FROM DE_ORTAK_MUSABAKA_ALANI
    GROUP BY MUSABAKA_ALANI_ID
) O
    ON O.MUSABAKA_ALANI_ID = F.MUSABAKA_ALANI_ID;
/



SELECT *
FROM DE_VW_FIKSTUR_MACLARI
ORDER BY
    FEDERASYON_ID,
    LIG_ID,
    HAFTA,
    MAC_TARIHI;
