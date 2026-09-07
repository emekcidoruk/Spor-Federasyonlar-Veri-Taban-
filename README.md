# 🏟️ Spor Federasyonları Veri Tabanı ve Analiz Sistemi

Bu proje, **Oracle PL/SQL** üzerinde geliştirilen spor federasyonları veri tabanı sisteminin **Python, Pandas ve Matplotlib** kullanılarak görselleştirilmesini amaçlamaktadır.

Sistem; **futbol, basketbol ve voleybol** branşlarında lig, takım, fikstür, puan durumu, skor log ve ceza log verilerini Oracle üzerindeki view'lerden okuyarak kullanıcıya görsel tablolar halinde sunmaktadır.

---

## 📌 Proje Özellikleri

- ⚽ Futbol puan durumu
- 🏀 Basketbol puan durumu
- 🏐 Voleybol puan durumu
- 📅 Lig ve hafta bazlı fikstür görüntüleme
- 📊 Branşa özel skor log görüntüleme
- 🟥 Branşa özel ceza log görüntüleme
- 🔎 Lig, hafta ve takım filtreleme
- 🗄️ Oracle View'lerinden veri çekme
- 🐼 Pandas DataFrame ile veri işleme
- 📈 Matplotlib ile tablo görselleştirme
- 💾 Görselleri PNG olarak kaydetme
- 📏 Tablo boyutlarını otomatik ve manuel ayarlama

---

# 🛠️ Kullanılan Teknolojiler

| Teknoloji | Kullanım Alanı |
|---|---|
| Oracle Database | Ana veri tabanı |
| PL/SQL | Procedure, Trigger ve View işlemleri |
| Python | Veri çekme ve görselleştirme |
| python-oracledb | Oracle bağlantısı |
| Pandas | Veri işleme |
| Matplotlib | Görsel tablo oluşturma |
| VS Code | Python geliştirme |
| PL/SQL Developer | Oracle geliştirme ortamı |

---

# 🗂️ Kullanılan Oracle View'leri

## ⚽ Futbol

```text
DE_VW_FUTBOL_PUAN_DURUMU
DE_VW_FUTBOL_SKOR_LOG
DE_VW_FUTBOL_CEZA_LOG
```

## 🏀 Basketbol

```text
DE_VW_BASKETBOL_PUAN_DURUMU
DE_VW_BASKETBOL_SKOR_LOG
DE_VW_BASKETBOL_CEZA_LOG
```

## 🏐 Voleybol

```text
DE_VW_VOLEYBOL_PUAN_DURUMU
DE_VW_VOLEYBOL_SKOR_LOG
DE_VW_VOLEYBOL_CEZA_LOG
```

## 📅 Fikstür

```text
DE_VW_FIKSTUR_MACLARI
```

---

# 📸 Uygulama Görselleri

## ⚽ Futbol Puan Durumu

Futbol puan durumunda takımlar;

- oynanan maç
- galibiyet
- beraberlik
- mağlubiyet
- atılan gol
- yenilen gol
- averaj
- puan

bilgileriyle görüntülenmektedir.

![Futbol Puan Durumu](./futbol_puan_durumu.png)

---

## 🏀 Basketbol Puan Durumu

Basketbol puan durumunda;

- oynanan maç
- galibiyet
- mağlubiyet
- atılan sayı
- yenilen sayı
- averaj
- puan

bilgileri görüntülenmektedir.

![Basketbol Puan Durumu](./basketbol_puan_durumu.png)

---

## 🏐 Voleybol Puan Durumu

Voleybol puan durumunda;

- oynanan maç
- galibiyet
- mağlubiyet
- alınan set
- verilen set
- set oranı
- puan

bilgileri görüntülenmektedir.

![Voleybol Puan Durumu](./voleybol_puan_durumu.png)

---

## 📅 Fikstür

Fikstür ekranında kullanıcı önce ligi, ardından haftayı seçmektedir.

Görüntülenen bilgiler:

- maç tarihi
- ev sahibi takım
- deplasman takımı
- müsabaka alanı
- maç sonucu

![Fikstür](./fikstur.png)

---

## ⚽ Skor Log

Skor Log ekranı branşa göre farklı View kullanmaktadır.

Görüntülenen bilgiler arasında:

- ev sahibi
- deplasman
- skoru yapan takım
- oyuncu
- skor türü
- skor değeri
- dakika
- periyot
- set
- maç sonucu

bulunmaktadır.

![Skor Log](./skor_log.png)

---

## 🟥 Ceza Log

Ceza Log ekranında;

- ev sahibi takım
- deplasman takımı
- ceza alan takım
- oyuncu
- ceza türü
- ceza nedeni
- dakika
- periyot
- set
- hakem
- maç sonucu

gibi bilgiler görüntülenmektedir.

![Ceza Log](./ceza_log.png)

---

# ⚙️ Kurulum

## 1. Projeyi Klonlayın

```bash
git clone <REPOSITORY_URL>
cd <REPOSITORY_FOLDER>
```

---

## 2. Gerekli Python Paketlerini Kurun

```bash
pip install oracledb pandas matplotlib
```

İsterseniz `requirements.txt` dosyası oluşturabilirsiniz:

```text
oracledb
pandas
matplotlib
```

Daha sonra:

```bash
pip install -r requirements.txt
```

---

# 🗄️ Oracle Instant Client

Proje Oracle bağlantısı için `python-oracledb` kütüphanesini Thick Mode ile kullanmaktadır.

`main.py` içerisindeki Instant Client yolu:

```python
oracledb.init_oracle_client(
    lib_dir=r"C:\instantclient_21_11"
)
```

Instant Client farklı bir klasördeyse bu yolu kendi bilgisayarınıza göre değiştirmeniz gerekir.

---

# 🔐 Oracle Bağlantı Bilgileri

`main.py` içerisinde bağlantı bilgileri aşağıdaki şekilde tanımlanmaktadır:

```python
host = "YOUR_ORACLE_HOST"
port = YOUR_ORACLE_PORT
service_name = "YOUR_SERVICE_NAME"
username = "YOUR_USERNAME"
```

Şifre program çalıştırıldığında kullanıcıdan gizli şekilde alınmaktadır:

```python
password = getpass.getpass(
    "Oracle şifreni gir: "
)
```

> ⚠️ Gerçek Oracle kullanıcı adı, şifre, IP adresi ve Service Name bilgilerini public GitHub repository içerisinde paylaşmayın.

---

# ▶️ Programı Çalıştırma

Terminal üzerinden:

```bash
python main.py
```

komutunu çalıştırın.

Program Oracle şifresini isteyecektir:

```text
Oracle şifreni gir:
```

Başarılı bağlantı sonrasında ana menü açılır:

```text
========================================
       SPOR FEDERASYONLARI ANALİZ
========================================

1 - Futbol Puan Durumu
2 - Basketbol Puan Durumu
3 - Voleybol Puan Durumu
4 - Fikstür
5 - Skor Log
6 - Ceza Log
0 - Çıkış
```

---

# 🔎 Filtreleme Sistemi

## Lig Seçimi

Program Oracle View içerisindeki mevcut ligleri otomatik olarak getirir.

Örnek:

```text
LİGLER
--------------------
1 - Trendyol Süper Lig
2 - Trendyol 1. Lig
```

---

## Hafta Seçimi

Fikstür, Skor Log ve Ceza Log ekranlarında hafta seçimi yapılabilir.

```text
HAFTALAR
--------------------
1
2
3
4
5
...
```

---

## Takım Seçimi

Skor Log ve Ceza Log ekranlarında takım filtresi bulunmaktadır.

```text
0 - Tüm Takımlar
1 - Takım A
2 - Takım B
3 - Takım C
```

`0 - Tüm Takımlar` seçildiğinde seçilen lig ve haftadaki bütün kayıtlar görüntülenir.

---

# 📏 Tablo Boyutlandırma Sistemi

Tabloların boyutları `main.py` içerisindeki `TABLO_AYARLARI` bölümünden değiştirilebilir.

```python
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
```

Buradaki değerler:

```text
genislik     → Görselin yatay genişliği
yukseklik    → Görselin dikey yüksekliği
satir_boyutu → Tablo satırlarının yüksekliği
```

anlamına gelmektedir.

Skor Log ve Ceza Log tabloları fazla sütun içerdiği için diğer ekranlardan daha geniş tasarlanmıştır.

---

# 📐 Otomatik Sütun Genişliği

Program sütun genişliklerini içerikteki en uzun veriye göre otomatik hesaplamaktadır.

Örneğin uzun takım isimleri veya ceza nedenleri varsa ilgili sütun otomatik olarak daha geniş oluşturulur.

Bu işlem:

```python
sutun_genisliklerini_hesapla(df)
```

fonksiyonu ile gerçekleştirilmektedir.

---

# 🎨 Tablo Tasarımı

Tablolarda ortak bir görsel tasarım kullanılmaktadır.

### Başlık

- koyu arka plan
- beyaz başlık
- mavi tablo başlıkları

### Satırlar

Satırlar dönüşümlü olarak:

```text
Beyaz
Açık Gri
Beyaz
Açık Gri
```

şeklinde gösterilmektedir.

### Puan Durumu

Puan durumlarında:

- sıra sütunu mavi
- puan sütunu yeşil
- takım isimleri sola hizalı
- ilk üç takım özel kenarlıklarla vurgulanmış

şekilde gösterilmektedir.

---

# ⚽ Futbol Puan Durumu

Futbol puan durumu Oracle View üzerinden alınır:

```sql
SELECT *
FROM DE_VW_FUTBOL_PUAN_DURUMU
```

Tabloda:

```text
Sıra
Takım
O
G
B
M
AG
YG
AV
Puan
```

alanları gösterilir.

---

# 🏀 Basketbol Puan Durumu

Basketbol puan durumu:

```sql
SELECT *
FROM DE_VW_BASKETBOL_PUAN_DURUMU
```

sorgusu ile alınır.

Gösterilen alanlar:

```text
Sıra
Takım
O
G
M
AS
YS
AV
Puan
```

---

# 🏐 Voleybol Puan Durumu

Voleybol puan durumu:

```sql
SELECT *
FROM DE_VW_VOLEYBOL_PUAN_DURUMU
```

üzerinden alınmaktadır.

Gösterilen alanlar:

```text
Sıra
Takım
O
G
M
AS
VS
Set Oranı
Puan
```

---

# 📅 Fikstür

Fikstür bilgileri:

```sql
SELECT *
FROM DE_VW_FIKSTUR_MACLARI
ORDER BY
    FEDERASYON_ID,
    LIG_ID,
    HAFTA,
    MAC_TARIHI
```

sorgusuyla alınır.

Kullanıcı:

```text
Lig
↓
Hafta
↓
Fikstür
```

şeklinde seçim yapar.

---

# 📊 Skor Log

Skor Log seçildiğinde kullanıcı önce branşı seçer.

```text
1 - Futbol
2 - Basketbol
3 - Voleybol
```

Branşa göre kullanılan View:

```text
Futbol
→ DE_VW_FUTBOL_SKOR_LOG

Basketbol
→ DE_VW_BASKETBOL_SKOR_LOG

Voleybol
→ DE_VW_VOLEYBOL_SKOR_LOG
```

Ardından:

```text
Lig
↓
Hafta
↓
Takım
↓
Skor Log
```

filtreleme akışı uygulanır.

---

# 🟥 Ceza Log

Ceza Log için de branşa göre farklı View kullanılmaktadır.

```text
Futbol
→ DE_VW_FUTBOL_CEZA_LOG

Basketbol
→ DE_VW_BASKETBOL_CEZA_LOG

Voleybol
→ DE_VW_VOLEYBOL_CEZA_LOG
```

Kullanıcı:

```text
Branş
↓
Lig
↓
Hafta
↓
Takım
↓
Ceza Log
```

şeklinde filtreleme yapabilir.

---

# 💾 Oluşturulan Görsel Dosyalar

Program çalıştırıldığında seçilen ekrana göre aşağıdaki PNG dosyalarından biri oluşturulur:

```text
futbol_puan_durumu.png
basketbol_puan_durumu.png
voleybol_puan_durumu.png
fikstur.png
skor_log.png
ceza_log.png
```

---

# 🔄 Program Akışı

```text
Oracle Database
       │
       ▼
PL/SQL View
       │
       ▼
python-oracledb
       │
       ▼
Pandas DataFrame
       │
       ▼
Lig Seçimi
       │
       ▼
Hafta Seçimi
       │
       ▼
Takım Seçimi
       │
       ▼
Matplotlib
       │
       ▼
PNG Tablo Görseli
```

---

# 📁 Önerilen Proje Yapısı

```text
spor-federasyonlari/
│
├── main.py
├── README.md
├── requirements.txt
│
├── futbol_puan_durumu.png
├── basketbol_puan_durumu.png
├── voleybol_puan_durumu.png
├── fikstur.png
├── skor_log.png
└── ceza_log.png
```

PNG dosyaları `README.md` ile aynı klasörde bulunduğunda GitHub üzerinde görseller otomatik olarak görüntülenir.

---

# 🎯 Projenin Amacı

Bu projenin temel amacı, Oracle PL/SQL üzerinde geliştirilen spor federasyonları veri tabanı sistemindeki verileri daha anlaşılır ve görsel bir yapıya dönüştürmektir.

Oracle tarafında;

- tablolar
- ilişkiler
- procedure'ler
- trigger'lar
- view'ler
- fikstür sistemi
- puan durumu
- skor log
- ceza log

gibi işlemler gerçekleştirilirken, Python tarafı veri tabanındaki sonuçların kullanıcıya görsel olarak sunulmasını sağlamaktadır.

Bu sayede veri tabanı ve görselleştirme katmanları birbirinden ayrılmış, daha düzenli bir mimari oluşturulmuştur.

---

# 🔐 Güvenlik

Public GitHub repository kullanırken aşağıdaki bilgileri paylaşmayın:

```text
Oracle kullanıcı adı
Oracle şifresi
Veri tabanı IP adresi
Service Name
VPN bilgileri
Kuruma ait özel bağlantı bilgileri
```

`main.py` dosyasını GitHub'a göndermeden önce bağlantı bilgilerini:

```python
host = "YOUR_ORACLE_HOST"
port = YOUR_ORACLE_PORT
service_name = "YOUR_SERVICE_NAME"
username = "YOUR_USERNAME"
```

şeklinde değiştirmek önerilir.

---

# 👨‍💻 Geliştirici

**Ad Soyad**  
Bilgisayar Mühendisliği

GitHub:

```text
https://github.com/emekcidoruk65
```

---

# 📄 Lisans

Bu proje eğitim ve staj çalışması kapsamında geliştirilmiştir.
