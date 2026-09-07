/* =========================================================
   DE_CEZA_TURU DUMMY DATA

   FEDERASYON_ID
   1 = FUTBOL
   2 = BASKETBOL
   3 = VOLEYBOL

   CEZA_TURU_ID      -> IDENTITY otomatik
   ISLEM_TARIHI      -> DEFAULT SYSDATE otomatik
   ========================================================= */

INSERT INTO DE_CEZA_TURU (
    FEDERASYON_ID,
    CEZA_TURU_ADI
)

SELECT 1, 'Sarý Kart' FROM DUAL

UNION ALL
SELECT 1, 'Kýrmýzý Kart' FROM DUAL

UNION ALL
SELECT 1, 'Ýkinci Sarý Karttan Kýrmýzý Kart' FROM DUAL

UNION ALL
SELECT 1, 'Sportmenliðe Aykýrý Hareket' FROM DUAL

UNION ALL
SELECT 1, 'Hakeme Ýtiraz' FROM DUAL

UNION ALL
SELECT 1, 'Hakaretten Ýhraç' FROM DUAL

UNION ALL
SELECT 1, 'Þiddetli Hareket' FROM DUAL

UNION ALL
SELECT 1, 'Ciddi Faullü Oyun' FROM DUAL

UNION ALL
SELECT 1, 'Maçtan Men' FROM DUAL

UNION ALL
SELECT 1, 'Disiplin Cezasý' FROM DUAL


/* =========================================================
   BASKETBOL
   ========================================================= */

UNION ALL
SELECT 2, 'Kiþisel Faul' FROM DUAL

UNION ALL
SELECT 2, 'Teknik Faul' FROM DUAL

UNION ALL
SELECT 2, 'Sportmenlik Dýþý Faul' FROM DUAL

UNION ALL
SELECT 2, 'Diskalifiye Edici Faul' FROM DUAL

UNION ALL
SELECT 2, 'Çift Teknik Faul' FROM DUAL

UNION ALL
SELECT 2, 'Oyundan Ýhraç' FROM DUAL

UNION ALL
SELECT 2, 'Maçtan Men' FROM DUAL

UNION ALL
SELECT 2, 'Disiplin Cezasý' FROM DUAL


/* =========================================================
   VOLEYBOL
   ========================================================= */

UNION ALL
SELECT 3, 'Sarý Kart Uyarýsý' FROM DUAL

UNION ALL
SELECT 3, 'Kýrmýzý Kart Cezasý' FROM DUAL

UNION ALL
SELECT 3, 'Oyundan Çýkarma' FROM DUAL

UNION ALL
SELECT 3, 'Diskalifiye' FROM DUAL

UNION ALL
SELECT 3, 'Sportmenliðe Aykýrý Davranýþ' FROM DUAL

UNION ALL
SELECT 3, 'Hakeme Ýtiraz' FROM DUAL

UNION ALL
SELECT 3, 'Geciktirme Cezasý' FROM DUAL

UNION ALL
SELECT 3, 'Disiplin Cezasý' FROM DUAL;

COMMIT;
