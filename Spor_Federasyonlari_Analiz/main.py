import oracledb
import getpass
import pandas as pd
import matplotlib.pyplot as plt


# ============================================================
# 1. TABLO BOYUT AYARLARI
# ============================================================
#
# Sadece buradaki değerleri değiştirmen yeterli.
#
# genislik     = görselin yatay boyutu
# yukseklik    = görselin dikey boyutu
# satir_boyutu = tablo satırlarının yüksekliği
#
# ============================================================

TABLO_AYARLARI = {

    "PUAN": {
        "genislik": 18,
        "yukseklik": 9,
        "satir_boyutu": 1.4
    },

    "FIKSTUR": {
        "genislik": 20,
        "yukseklik": 9,
        "satir_boyutu": 1.5
    },

    "SKOR_LOG": {
        "genislik": 30,
        "yukseklik": 14,
        "satir_boyutu": 1.8
    },

    "CEZA_LOG": {
        "genislik": 35,
        "yukseklik": 15,
        "satir_boyutu": 1.9
    }
}


# ============================================================
# 2. ORACLE INSTANT CLIENT
# ============================================================

oracledb.init_oracle_client(
    lib_dir=r"C:\instantclient_21_11"
)


# ============================================================
# 3. ORACLE BAĞLANTI BİLGİLERİ
# ============================================================

host = "YOUR_ORACLE_HOST"
port = YOUR_ORACLE_PORT
service_name = "YOUR_SERVICE_NAME"
username = "YOUR_USERNAME"

password = getpass.getpass(
    "Oracle şifreni gir: "
)


# ============================================================
# 4. ORACLE BAĞLANTISI
# ============================================================

try:

    baglanti = oracledb.connect(
        user=username,
        password=password,
        host=host,
        port=port,
        service_name=service_name
    )

    print("\nOracle bağlantısı başarılı.")

except Exception as hata:

    print("\nOracle bağlantı hatası:")
    print(hata)

    exit()


# ============================================================
# 5. LİG SEÇİMİ
# ============================================================

def lig_sec(df):

    ligler = (
        df["LIG_ADI"]
        .dropna()
        .unique()
    )

    if len(ligler) == 0:

        print("\nLig bulunamadı.")
        return None


    print("\nLİGLER")
    print("--------------------")


    for i, lig in enumerate(
        ligler,
        start=1
    ):

        print(
            f"{i} - {lig}"
        )


    try:

        secim = int(
            input("\nLig seçiniz: ")
        )


        if secim < 1 or secim > len(ligler):

            print(
                "Geçersiz lig seçimi."
            )

            return None


        return ligler[
            secim - 1
        ]


    except ValueError:

        print(
            "Lütfen sayı giriniz."
        )

        return None


# ============================================================
# 6. HAFTA SEÇİMİ
# ============================================================

def hafta_sec(df):

    haftalar = sorted(
        df["HAFTA"]
        .dropna()
        .unique()
    )


    if len(haftalar) == 0:

        print(
            "\nHafta bulunamadı."
        )

        return None


    print("\nHAFTALAR")
    print("--------------------")


    for hafta in haftalar:

        print(
            hafta
        )


    try:

        secim = int(
            input(
                "\nHafta seçiniz: "
            )
        )


        if secim not in haftalar:

            print(
                "Geçersiz hafta."
            )

            return None


        return secim


    except ValueError:

        print(
            "Lütfen sayı giriniz."
        )

        return None


# ============================================================
# 7. TAKIM SEÇİMİ
# ============================================================

def takim_sec(df):

    takimlar = []


    # --------------------------------------------------------
    # View'da hangi takım sütunları varsa onlardan takımları al
    # --------------------------------------------------------

    takim_sutunlari = [

        "TAKIM_ADI",

        "SKOR_YAPAN_TAKIM_ADI",

        "EV_SAHIBI_TAKIM_ADI",

        "DEPLASMAN_TAKIM_ADI"
    ]


    for sutun in takim_sutunlari:

        if sutun in df.columns:

            takimlar.extend(

                df[sutun]
                .dropna()
                .astype(str)
                .tolist()
            )


    takimlar = sorted(
        set(takimlar)
    )


    if len(takimlar) == 0:

        print(
            "\nTakım bulunamadı."
        )

        return None


    print("\nTAKIMLAR")
    print("--------------------")

    print(
        "0 - Tüm Takımlar"
    )


    for i, takim in enumerate(
        takimlar,
        start=1
    ):

        print(
            f"{i} - {takim}"
        )


    try:

        secim = int(
            input(
                "\nTakım seçiniz: "
            )
        )


        if secim == 0:

            return "TUMU"


        if (
            secim < 1
            or
            secim > len(takimlar)
        ):

            print(
                "Geçersiz takım seçimi."
            )

            return None


        return takimlar[
            secim - 1
        ]


    except ValueError:

        print(
            "Lütfen sayı giriniz."
        )

        return None


# ============================================================
# 8. OTOMATİK SÜTUN GENİŞLİĞİ
# ============================================================

def sutun_genisliklerini_hesapla(df):

    genislikler = []


    for sutun in df.columns:

        en_uzun_veri = (
            df[sutun]
            .astype(str)
            .map(len)
            .max()
        )


        en_uzun = max(
            len(str(sutun)),
            en_uzun_veri
        )


        genislik = (
            en_uzun * 0.012
        )


        if genislik < 0.08:

            genislik = 0.08


        if genislik > 0.40:

            genislik = 0.40


        genislikler.append(
            genislik
        )


    return genislikler


# ============================================================
# 9. GENEL TABLO GÖSTERME
# ============================================================

def tablo_goster(
    df,
    baslik,
    alt_baslik,
    dosya_adi,
    tablo_tipi
):

    if df.empty:

        print(
            "\nGösterilecek veri bulunamadı."
        )

        return


    ayar = TABLO_AYARLARI[
        tablo_tipi
    ]


    df = df.copy()

    df = df.fillna("-")


    # ========================================================
    # OTOMATİK GÖRSEL GENİŞLİĞİ
    # ========================================================

    toplam_karakter = 0


    for sutun in df.columns:

        en_uzun = max(

            len(str(sutun)),

            df[sutun]
            .astype(str)
            .map(len)
            .max()
        )


        toplam_karakter += (
            en_uzun
        )


    otomatik_genislik = max(

        ayar[
            "genislik"
        ],

        toplam_karakter
        * 0.105
    )


    otomatik_yukseklik = max(

        ayar[
            "yukseklik"
        ],

        len(df)
        * 0.55
        + 4
    )


    # ========================================================
    # FIGURE
    # ========================================================

    fig, ax = plt.subplots(

        figsize=(
            otomatik_genislik,
            otomatik_yukseklik
        )
    )


    fig.patch.set_facecolor(
        "#0F172A"
    )


    ax.set_facecolor(
        "#0F172A"
    )


    ax.axis(
        "off"
    )


    # ========================================================
    # BAŞLIK
    # ========================================================

    fig.text(

        0.5,
        0.96,

        baslik,

        ha="center",
        va="top",

        fontsize=20,

        fontweight="bold",

        color="white"
    )


    fig.text(

        0.5,
        0.91,

        alt_baslik,

        ha="center",
        va="top",

        fontsize=12,

        color="#CBD5E1"
    )


    # ========================================================
    # OTOMATİK SÜTUN GENİŞLİKLERİ
    # ========================================================

    col_widths = (
        sutun_genisliklerini_hesapla(
            df
        )
    )


    # ========================================================
    # TABLO
    # ========================================================

    tablo = ax.table(

        cellText=df.values,

        colLabels=df.columns,

        cellLoc="center",

        colLoc="center",

        loc="center",

        bbox=[
            0.01,
            0.02,
            0.98,
            0.82
        ],

        colWidths=col_widths
    )


    tablo.auto_set_font_size(
        False
    )


    tablo.set_fontsize(
        9
    )


    # ========================================================
    # HEADER
    # ========================================================

    for j in range(
        len(df.columns)
    ):

        hucre = tablo[
            (0, j)
        ]


        hucre.set_facecolor(
            "#1D4ED8"
        )


        hucre.set_text_props(

            color="white",

            fontweight="bold",

            fontsize=10
        )


        hucre.set_edgecolor(
            "#60A5FA"
        )


        hucre.set_linewidth(
            1.0
        )


    # ========================================================
    # SATIRLAR
    # ========================================================

    for i in range(
        1,
        len(df) + 1
    ):

        for j in range(
            len(df.columns)
        ):

            hucre = tablo[
                (i, j)
            ]


            if i % 2 == 0:

                hucre.set_facecolor(
                    "#E2E8F0"
                )

            else:

                hucre.set_facecolor(
                    "#FFFFFF"
                )


            hucre.set_text_props(
                color="#0F172A"
            )


            hucre.set_edgecolor(
                "#CBD5E1"
            )


            hucre.set_linewidth(
                0.5
            )


    # ========================================================
    # PUAN DURUMU ÖZEL STİL
    # ========================================================

    if tablo_tipi == "PUAN":


        # ----------------------------------------------------
        # SIRA
        # ----------------------------------------------------

        if "Sıra" in df.columns:

            index = (
                df.columns.get_loc(
                    "Sıra"
                )
            )


            for i in range(
                1,
                len(df) + 1
            ):

                hucre = tablo[
                    (i, index)
                ]


                hucre.set_facecolor(
                    "#DBEAFE"
                )


                hucre.set_text_props(

                    color="#1E3A8A",

                    fontweight="bold"
                )


        # ----------------------------------------------------
        # PUAN
        # ----------------------------------------------------

        if "Puan" in df.columns:

            index = (
                df.columns.get_loc(
                    "Puan"
                )
            )


            for i in range(
                1,
                len(df) + 1
            ):

                hucre = tablo[
                    (i, index)
                ]


                hucre.set_facecolor(
                    "#DCFCE7"
                )


                hucre.set_text_props(

                    color="#166534",

                    fontweight="bold"
                )


        # ----------------------------------------------------
        # TAKIM SOLA HİZALI
        # ----------------------------------------------------

        if "Takım" in df.columns:

            index = (
                df.columns.get_loc(
                    "Takım"
                )
            )


            for i in range(
                1,
                len(df) + 1
            ):

                tablo[
                    (i, index)
                ].get_text().set_ha(
                    "left"
                )


        # ----------------------------------------------------
        # İLK 3
        # ----------------------------------------------------

        for i in range(

            1,

            min(
                4,
                len(df) + 1
            )
        ):

            for j in range(
                len(df.columns)
            ):

                hucre = tablo[
                    (i, j)
                ]


                if i == 1:

                    hucre.set_edgecolor(
                        "#F59E0B"
                    )

                    hucre.set_linewidth(
                        1.8
                    )


                elif i == 2:

                    hucre.set_edgecolor(
                        "#94A3B8"
                    )

                    hucre.set_linewidth(
                        1.5
                    )


                elif i == 3:

                    hucre.set_edgecolor(
                        "#B45309"
                    )

                    hucre.set_linewidth(
                        1.3
                    )


    # ========================================================
    # SATIR YÜKSEKLİĞİ
    # ========================================================

    tablo.scale(

        1.0,

        ayar[
            "satir_boyutu"
        ]
    )


    # ========================================================
    # KAYDET
    # ========================================================

    plt.savefig(

        dosya_adi,

        dpi=180,

        bbox_inches="tight",

        facecolor=fig.get_facecolor()
    )


    plt.show()


    print(
        f"\n'{dosya_adi}' olarak kaydedildi."
    )


# ============================================================
# 10. ANA MENÜ
# ============================================================

print(
    "\n========================================"
)

print(
    "       SPOR FEDERASYONLARI ANALİZ"
)

print(
    "========================================"
)


print(
    "1 - Futbol Puan Durumu"
)

print(
    "2 - Basketbol Puan Durumu"
)

print(
    "3 - Voleybol Puan Durumu"
)

print(
    "4 - Fikstür"
)

print(
    "5 - Skor Log"
)

print(
    "6 - Ceza Log"
)

print(
    "0 - Çıkış"
)


secim = input(
    "\nSeçiminizi girin: "
)


# ============================================================
# 11. FUTBOL PUAN DURUMU
# ============================================================

if secim == "1":

    sorgu = """
        SELECT *
        FROM DE_VW_FUTBOL_PUAN_DURUMU
    """


    df = pd.read_sql(
        sorgu,
        baglanti
    )


    if df.empty:

        print(
            "\nFutbol puan durumu bulunamadı."
        )


    else:

        secilen_lig = lig_sec(
            df
        )


        if secilen_lig is not None:

            lig_df = df[

                df["LIG_ADI"]
                ==
                secilen_lig

            ].copy()


            # =================================================
            # Puan > Averaj > Atılan Gol
            # =================================================

            lig_df = (

                lig_df

                .sort_values(

                    by=[
                        "PUAN",
                        "AVERAJ",
                        "ATILAN_GOL"
                    ],

                    ascending=[
                        False,
                        False,
                        False
                    ]
                )

                .reset_index(
                    drop=True
                )
            )


            lig_df["SIRA"] = range(

                1,

                len(lig_df) + 1
            )


            tablo = lig_df[

                [
                    "SIRA",
                    "TAKIM_ADI",
                    "OYNANAN_MAC",
                    "GALIBIYET",
                    "BERABERLIK",
                    "MAGLUBIYET",
                    "ATILAN_GOL",
                    "YENILEN_GOL",
                    "AVERAJ",
                    "PUAN"
                ]

            ].copy()


            tablo.rename(

                columns={

                    "SIRA":
                        "Sıra",

                    "TAKIM_ADI":
                        "Takım",

                    "OYNANAN_MAC":
                        "O",

                    "GALIBIYET":
                        "G",

                    "BERABERLIK":
                        "B",

                    "MAGLUBIYET":
                        "M",

                    "ATILAN_GOL":
                        "AG",

                    "YENILEN_GOL":
                        "YG",

                    "AVERAJ":
                        "AV",

                    "PUAN":
                        "Puan"
                },

                inplace=True
            )


            tablo_goster(

                tablo,

                "FUTBOL PUAN DURUMU",

                secilen_lig,

                "futbol_puan_durumu.png",

                "PUAN"
            )


# ============================================================
# 12. BASKETBOL PUAN DURUMU
# ============================================================

elif secim == "2":

    sorgu = """
        SELECT *
        FROM DE_VW_BASKETBOL_PUAN_DURUMU
    """


    df = pd.read_sql(
        sorgu,
        baglanti
    )


    if df.empty:

        print(
            "\nBasketbol puan durumu bulunamadı."
        )


    else:

        secilen_lig = lig_sec(
            df
        )


        if secilen_lig is not None:

            lig_df = df[

                df["LIG_ADI"]
                ==
                secilen_lig

            ].copy()


            # =================================================
            # Puan > Toplam Averaj > Atılan Sayı
            # =================================================

            lig_df = (

                lig_df

                .sort_values(

                    by=[
                        "PUAN",
                        "TOPLAM_AVERAJ",
                        "ATILAN_SAYI"
                    ],

                    ascending=[
                        False,
                        False,
                        False
                    ]
                )

                .reset_index(
                    drop=True
                )
            )


            lig_df["SIRA"] = range(

                1,

                len(lig_df) + 1
            )


            tablo = lig_df[

                [
                    "SIRA",
                    "TAKIM_ADI",
                    "OYNANAN_MAC",
                    "GALIBIYET",
                    "MAGLUBIYET",
                    "ATILAN_SAYI",
                    "YENILEN_SAYI",
                    "TOPLAM_AVERAJ",
                    "PUAN"
                ]

            ].copy()


            tablo.rename(

                columns={

                    "SIRA":
                        "Sıra",

                    "TAKIM_ADI":
                        "Takım",

                    "OYNANAN_MAC":
                        "O",

                    "GALIBIYET":
                        "G",

                    "MAGLUBIYET":
                        "M",

                    "ATILAN_SAYI":
                        "AS",

                    "YENILEN_SAYI":
                        "YS",

                    "TOPLAM_AVERAJ":
                        "AV",

                    "PUAN":
                        "Puan"
                },

                inplace=True
            )


            tablo_goster(

                tablo,

                "BASKETBOL PUAN DURUMU",

                secilen_lig,

                "basketbol_puan_durumu.png",

                "PUAN"
            )


# ============================================================
# 13. VOLEYBOL PUAN DURUMU
# ============================================================

elif secim == "3":

    sorgu = """
        SELECT *
        FROM DE_VW_VOLEYBOL_PUAN_DURUMU
    """


    df = pd.read_sql(
        sorgu,
        baglanti
    )


    if df.empty:

        print(
            "\nVoleybol puan durumu bulunamadı."
        )


    else:

        secilen_lig = lig_sec(
            df
        )


        if secilen_lig is not None:

            lig_df = df[

                df["LIG_ADI"]
                ==
                secilen_lig

            ].copy()


            # =================================================
            # Puan > Set Oranı > Alınan Set
            # =================================================

            lig_df = (

                lig_df

                .sort_values(

                    by=[
                        "PUAN",
                        "SET_ORANI",
                        "ALINAN_SET"
                    ],

                    ascending=[
                        False,
                        False,
                        False
                    ]
                )

                .reset_index(
                    drop=True
                )
            )


            lig_df["SIRA"] = range(

                1,

                len(lig_df) + 1
            )


            tablo = lig_df[

                [
                    "SIRA",
                    "TAKIM_ADI",
                    "OYNANAN_MAC",
                    "GALIBIYET",
                    "MAGLUBIYET",
                    "ALINAN_SET",
                    "VERILEN_SET",
                    "SET_ORANI",
                    "PUAN"
                ]

            ].copy()


            tablo.rename(

                columns={

                    "SIRA":
                        "Sıra",

                    "TAKIM_ADI":
                        "Takım",

                    "OYNANAN_MAC":
                        "O",

                    "GALIBIYET":
                        "G",

                    "MAGLUBIYET":
                        "M",

                    "ALINAN_SET":
                        "AS",

                    "VERILEN_SET":
                        "VS",

                    "SET_ORANI":
                        "Set Oranı",

                    "PUAN":
                        "Puan"
                },

                inplace=True
            )


            tablo_goster(

                tablo,

                "VOLEYBOL PUAN DURUMU",

                secilen_lig,

                "voleybol_puan_durumu.png",

                "PUAN"
            )


# ============================================================
# 14. FİKSTÜR
# ============================================================

elif secim == "4":

    sorgu = """
        SELECT *
        FROM DE_VW_FIKSTUR_MACLARI
        ORDER BY
            FEDERASYON_ID,
            LIG_ID,
            HAFTA,
            MAC_TARIHI
    """


    df = pd.read_sql(
        sorgu,
        baglanti
    )


    if df.empty:

        print(
            "\nFikstür bulunamadı."
        )


    else:

        secilen_lig = lig_sec(
            df
        )


        if secilen_lig is not None:

            lig_df = df[

                df["LIG_ADI"]
                ==
                secilen_lig

            ].copy()


            secilen_hafta = hafta_sec(
                lig_df
            )


            if secilen_hafta is not None:

                fikstur_df = lig_df[

                    lig_df["HAFTA"]
                    ==
                    secilen_hafta

                ].copy()


                sutunlar = [

                    "MAC_TARIHI",

                    "EV_SAHIBI_TAKIM_ADI",

                    "DEPLASMAN_TAKIM_ADI",

                    "MUSABAKA_ALANI_ADI",

                    "MAC_SONUCU"
                ]


                mevcut = [

                    s

                    for s in sutunlar

                    if s
                    in fikstur_df.columns
                ]


                tablo = fikstur_df[
                    mevcut
                ].copy()


                # =================================================
                # TARİH
                # =================================================

                if (
                    "MAC_TARIHI"
                    in tablo.columns
                ):

                    tablo[
                        "MAC_TARIHI"
                    ] = (

                        pd.to_datetime(

                            tablo[
                                "MAC_TARIHI"
                            ],

                            errors="coerce"
                        )

                        .dt.strftime(
                            "%d.%m.%Y"
                        )
                    )


                # =================================================
                # OYNANMAMIŞ MAÇ
                # =================================================

                if (
                    "MAC_SONUCU"
                    in tablo.columns
                ):

                    tablo[
                        "MAC_SONUCU"
                    ] = (

                        tablo[
                            "MAC_SONUCU"
                        ]

                        .fillna(
                            "Oynanmadı"
                        )
                    )


                tablo.rename(

                    columns={

                        "MAC_TARIHI":
                            "Tarih",

                        "EV_SAHIBI_TAKIM_ADI":
                            "Ev Sahibi",

                        "DEPLASMAN_TAKIM_ADI":
                            "Deplasman",

                        "MUSABAKA_ALANI_ADI":
                            "Müsabaka Alanı",

                        "MAC_SONUCU":
                            "Sonuç"
                    },

                    inplace=True
                )


                tablo_goster(

                    tablo,

                    "FİKSTÜR",

                    (
                        f"{secilen_lig} - "
                        f"{secilen_hafta}. Hafta"
                    ),

                    "fikstur.png",

                    "FIKSTUR"
                )


# ============================================================
# 15. SKOR LOG
# ============================================================

elif secim == "5":

    print(
        "\nBRANŞ SEÇİN"
    )

    print(
        "--------------------"
    )


    print(
        "1 - Futbol"
    )

    print(
        "2 - Basketbol"
    )

    print(
        "3 - Voleybol"
    )


    brans = input(
        "\nSeçiminiz: "
    )


    if brans == "1":

        view_adi = (
            "DE_VW_FUTBOL_SKOR_LOG"
        )

        baslik = (
            "FUTBOL SKOR LOG"
        )


    elif brans == "2":

        view_adi = (
            "DE_VW_BASKETBOL_SKOR_LOG"
        )

        baslik = (
            "BASKETBOL SKOR LOG"
        )


    elif brans == "3":

        view_adi = (
            "DE_VW_VOLEYBOL_SKOR_LOG"
        )

        baslik = (
            "VOLEYBOL SKOR LOG"
        )


    else:

        print(
            "\nGeçersiz branş."
        )

        baglanti.close()

        exit()


    sorgu = f"""
        SELECT *
        FROM {view_adi}
        ORDER BY
            LIG_ID,
            HAFTA,
            FIKSTUR_ID
    """


    df = pd.read_sql(
        sorgu,
        baglanti
    )


    if df.empty:

        print(
            "\nSkor log bulunamadı."
        )


    else:

        # ====================================================
        # LİG
        # ====================================================

        secilen_lig = lig_sec(
            df
        )


        if secilen_lig is not None:

            lig_df = df[

                df["LIG_ADI"]
                ==
                secilen_lig

            ].copy()


            # =================================================
            # HAFTA
            # =================================================

            secilen_hafta = hafta_sec(
                lig_df
            )


            if secilen_hafta is not None:

                skor_df = lig_df[

                    lig_df["HAFTA"]
                    ==
                    secilen_hafta

                ].copy()


                # =================================================
                # TAKIM SEÇ
                # =================================================

                secilen_takim = takim_sec(
                    skor_df
                )


                if secilen_takim is not None:


                    # =============================================
                    # SEÇİLEN TAKIMIN SKORLARINI FİLTRELE
                    # =============================================

                    if (
                        secilen_takim
                        !=
                        "TUMU"
                    ):


                        if (
                            "SKOR_YAPAN_TAKIM_ADI"
                            in skor_df.columns
                        ):

                            skor_df = skor_df[

                                skor_df[
                                    "SKOR_YAPAN_TAKIM_ADI"
                                ]
                                ==
                                secilen_takim

                            ].copy()


                        else:

                            filtre = pd.Series(

                                False,

                                index=skor_df.index
                            )


                            if (
                                "EV_SAHIBI_TAKIM_ADI"
                                in skor_df.columns
                            ):

                                filtre |= (

                                    skor_df[
                                        "EV_SAHIBI_TAKIM_ADI"
                                    ]
                                    ==
                                    secilen_takim
                                )


                            if (
                                "DEPLASMAN_TAKIM_ADI"
                                in skor_df.columns
                            ):

                                filtre |= (

                                    skor_df[
                                        "DEPLASMAN_TAKIM_ADI"
                                    ]
                                    ==
                                    secilen_takim
                                )


                            skor_df = skor_df[
                                filtre
                            ].copy()


                    # =============================================
                    # TABLO SÜTUNLARI
                    # =============================================

                    sutunlar = [

                        "EV_SAHIBI_TAKIM_ADI",

                        "DEPLASMAN_TAKIM_ADI",

                        "SKOR_YAPAN_TAKIM_ADI",

                        "OYUNCU_ADI_SOYADI",

                        "SKOR_TURU",

                        "SKOR_DEGERI",

                        "DAKIKA",

                        "PERIYOT",

                        "SET_NO",

                        "MAC_SONUCU"
                    ]


                    mevcut = [

                        s

                        for s in sutunlar

                        if s
                        in skor_df.columns
                    ]


                    tablo = skor_df[
                        mevcut
                    ].copy()


                    tablo.rename(

                        columns={

                            "EV_SAHIBI_TAKIM_ADI":
                                "Ev Sahibi",

                            "DEPLASMAN_TAKIM_ADI":
                                "Deplasman",

                            "SKOR_YAPAN_TAKIM_ADI":
                                "Skoru Yapan",

                            "OYUNCU_ADI_SOYADI":
                                "Oyuncu",

                            "SKOR_TURU":
                                "Skor Türü",

                            "SKOR_DEGERI":
                                "Değer",

                            "DAKIKA":
                                "Dakika",

                            "PERIYOT":
                                "Periyot",

                            "SET_NO":
                                "Set",

                            "MAC_SONUCU":
                                "Sonuç"
                        },

                        inplace=True
                    )


                    # =============================================
                    # ALT BAŞLIK
                    # =============================================

                    if (
                        secilen_takim
                        ==
                        "TUMU"
                    ):

                        takim_baslik = (
                            "Tüm Takımlar"
                        )

                    else:

                        takim_baslik = (
                            secilen_takim
                        )


                    tablo_goster(

                        tablo,

                        baslik,

                        (
                            f"{secilen_lig} - "
                            f"{secilen_hafta}. Hafta - "
                            f"{takim_baslik}"
                        ),

                        "skor_log.png",

                        "SKOR_LOG"
                    )


# ============================================================
# 16. CEZA LOG
# ============================================================

elif secim == "6":

    print(
        "\nBRANŞ SEÇİN"
    )

    print(
        "--------------------"
    )


    print(
        "1 - Futbol"
    )

    print(
        "2 - Basketbol"
    )

    print(
        "3 - Voleybol"
    )


    brans = input(
        "\nSeçiminiz: "
    )


    if brans == "1":

        view_adi = (
            "DE_VW_FUTBOL_CEZA_LOG"
        )

        baslik = (
            "FUTBOL CEZA LOG"
        )


    elif brans == "2":

        view_adi = (
            "DE_VW_BASKETBOL_CEZA_LOG"
        )

        baslik = (
            "BASKETBOL CEZA LOG"
        )


    elif brans == "3":

        view_adi = (
            "DE_VW_VOLEYBOL_CEZA_LOG"
        )

        baslik = (
            "VOLEYBOL CEZA LOG"
        )


    else:

        print(
            "\nGeçersiz branş."
        )

        baglanti.close()

        exit()


    sorgu = f"""
        SELECT *
        FROM {view_adi}
        ORDER BY
            LIG_ID,
            HAFTA,
            FIKSTUR_ID
    """


    df = pd.read_sql(
        sorgu,
        baglanti
    )


    if df.empty:

        print(
            "\nCeza log bulunamadı."
        )


    else:

        # ====================================================
        # LİG
        # ====================================================

        secilen_lig = lig_sec(
            df
        )


        if secilen_lig is not None:

            lig_df = df[

                df["LIG_ADI"]
                ==
                secilen_lig

            ].copy()


            # =================================================
            # HAFTA
            # =================================================

            secilen_hafta = hafta_sec(
                lig_df
            )


            if secilen_hafta is not None:

                ceza_df = lig_df[

                    lig_df["HAFTA"]
                    ==
                    secilen_hafta

                ].copy()


                # =================================================
                # TAKIM SEÇ
                # =================================================

                secilen_takim = takim_sec(
                    ceza_df
                )


                if secilen_takim is not None:


                    # =============================================
                    # SEÇİLEN TAKIMIN CEZALARINI FİLTRELE
                    # =============================================

                    if (
                        secilen_takim
                        !=
                        "TUMU"
                    ):


                        if (
                            "TAKIM_ADI"
                            in ceza_df.columns
                        ):

                            ceza_df = ceza_df[

                                ceza_df[
                                    "TAKIM_ADI"
                                ]
                                ==
                                secilen_takim

                            ].copy()


                        else:

                            filtre = pd.Series(

                                False,

                                index=ceza_df.index
                            )


                            if (
                                "EV_SAHIBI_TAKIM_ADI"
                                in ceza_df.columns
                            ):

                                filtre |= (

                                    ceza_df[
                                        "EV_SAHIBI_TAKIM_ADI"
                                    ]
                                    ==
                                    secilen_takim
                                )


                            if (
                                "DEPLASMAN_TAKIM_ADI"
                                in ceza_df.columns
                            ):

                                filtre |= (

                                    ceza_df[
                                        "DEPLASMAN_TAKIM_ADI"
                                    ]
                                    ==
                                    secilen_takim
                                )


                            ceza_df = ceza_df[
                                filtre
                            ].copy()


                    # =============================================
                    # TABLO SÜTUNLARI
                    # =============================================

                    sutunlar = [

                        "EV_SAHIBI_TAKIM_ADI",

                        "DEPLASMAN_TAKIM_ADI",

                        "TAKIM_ADI",

                        "OYUNCU_ADI_SOYADI",

                        "CEZA_TURU_ADI",

                        "CEZA_NEDENI",

                        "DAKIKA",

                        "PERIYOT",

                        "SET_NO",

                        "HAKEM_ADI_SOYADI",

                        "MAC_SONUCU"
                    ]


                    mevcut = [

                        s

                        for s in sutunlar

                        if s
                        in ceza_df.columns
                    ]


                    tablo = ceza_df[
                        mevcut
                    ].copy()


                    tablo.rename(

                        columns={

                            "EV_SAHIBI_TAKIM_ADI":
                                "Ev Sahibi",

                            "DEPLASMAN_TAKIM_ADI":
                                "Deplasman",

                            "TAKIM_ADI":
                                "Ceza Alan Takım",

                            "OYUNCU_ADI_SOYADI":
                                "Oyuncu",

                            "CEZA_TURU_ADI":
                                "Ceza Türü",

                            "CEZA_NEDENI":
                                "Neden",

                            "DAKIKA":
                                "Dakika",

                            "PERIYOT":
                                "Periyot",

                            "SET_NO":
                                "Set",

                            "HAKEM_ADI_SOYADI":
                                "Hakem",

                            "MAC_SONUCU":
                                "Sonuç"
                        },

                        inplace=True
                    )


                    # =============================================
                    # ALT BAŞLIK
                    # =============================================

                    if (
                        secilen_takim
                        ==
                        "TUMU"
                    ):

                        takim_baslik = (
                            "Tüm Takımlar"
                        )

                    else:

                        takim_baslik = (
                            secilen_takim
                        )


                    tablo_goster(

                        tablo,

                        baslik,

                        (
                            f"{secilen_lig} - "
                            f"{secilen_hafta}. Hafta - "
                            f"{takim_baslik}"
                        ),

                        "ceza_log.png",

                        "CEZA_LOG"
                    )


# ============================================================
# 17. ÇIKIŞ
# ============================================================

elif secim == "0":

    print(
        "\nProgramdan çıkılıyor..."
    )


else:

    print(
        "\nGeçersiz seçim."
    )


# ============================================================
# 18. ORACLE BAĞLANTISINI KAPAT
# ============================================================

baglanti.close()


print(
    "\nOracle bağlantısı kapatıldı."
)