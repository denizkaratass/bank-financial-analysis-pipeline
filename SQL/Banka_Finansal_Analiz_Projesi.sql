/*

PROJE ADI:   TÜRKÝYE BANKACILIK SEKTÖRÜ FÝNANSAL PERFORMANS VE RÝSK ANALÝZÝ
    
Bu proje, ham finansal verilerin iþlenmesi (ETL), operasyonel risklerin analiz edilmesi 
ve stratejik karar destek raporlarýnýn (Power BI için Views) hazýrlanmasýný kapsar.


KULLANILAN TEKNÝKLER (TECHNICAL STACK):
1. Veri Tipi Dönüþümü ve Temizliði (Data Type Casting & ETL Process)
2. Ýleri Analitik Fonksiyonlar (Window Functions: LAG, OVER, Moving Average)
3. Stratejik Segmentasyon (CTE & Pareto Analizi - 80/20 Kuralý)
4. Performans Metrikleri ve Raporlama Katmaný (Strategic KPIs & Reporting Views)
*/



-- BÖLÜM 1: VERÝ TÝPÝ DÖNÜÞÜMÜ (ETL PROCESS)

/*
DURUM ANALÝZÝ:
Veri güvenliðini saðlamak amacýyla tüm sütunlar sisteme ilk aþamada VARCHAR (Metin) 
formatýnda aktarýlmýþtýr (Staging Yöntemi).

UYGULAMA:
Kaynak verideki sayýsal formatýn (Nokta ayracý), SQL Server'ýn native (doðal) 
formatýyla uyumlu olduðu tespit edilmiþtir. Bu nedenle veri bütünlüðünü bozmamak adýna 
ek bir manipülasyon (Replace vb.) yapýlmadan doðrudan tip dönüþümü uygulanmýþtýr.
*/

-- Veriler analiz için uygun olan FLOAT (Ondalýk Sayý) formatýna dönüþtürülüyor:

ALTER TABLE dbo.Proje_Data ALTER COLUMN Diger_Riskler FLOAT;
ALTER TABLE dbo.Proje_Data ALTER COLUMN Net_Kar FLOAT;
ALTER TABLE dbo.Proje_Data ALTER COLUMN Kredi_Risk_Karsiligi FLOAT;
ALTER TABLE dbo.Proje_Data ALTER COLUMN Net_Faiz_Marji FLOAT;
ALTER TABLE dbo.Proje_Data ALTER COLUMN Faiz_Geliri FLOAT;
ALTER TABLE dbo.Proje_Data ALTER COLUMN Faiz_Gideri FLOAT;


SELECT * FROM dbo.Proje_Data




-- BÖLÜM 2: TEMEL DURUM ANALÝZLERÝ (DESCRIPTIVE ANALYTICS)

-- 1. Bankanýn tarihindeki en yüksek 'Net Kâr' rekoru ne zaman kýrýldý?

SELECT TOP 1
tarih, 
Net_Kar 
FROM dbo.Proje_Data
Order by Net_Kar desc;

-- 2. Kredi risklerinin 20 Milyar TL'yi aþtýðý "Kýrmýzý Alarm" aylarý hangileri?

SELECT 
tarih,
Kredi_Risk_Karsiligi,
Net_Kar
FROM dbo.Proje_Data 
WHERE Kredi_Risk_Karsiligi > 20000;

-- 3. Faiz Giderinin, Faiz Gelirini geçtiði (veya kafa kafaya geldiði) aylar var mý?
SELECT
    tarih,
    Faiz_Geliri,
    Faiz_Gideri
FROM dbo.Proje_Data
WHERE Faiz_Geliri < Faiz_Gideri;

--4. 2023, 2024 ve 2025 Yýllarýnýna Ait Toplam Net Kâr Tablosu

SELECT
    Year(tarih) AS Yýl,
    SUM(Net_Kar) AS Yýllýk_net_kar
FROM dbo.Proje_Data
GROUP BY Year(tarih)
ORDER BY Year(tarih);


-- 5. Hangi yýl toplamda en çok kârý elde ettik?


SELECT TOP 1 
    YEAR(tarih) AS Yil, 
    SUM(Net_Kar) AS Toplam_Kar  
FROM dbo.Proje_Data
GROUP BY YEAR(tarih)           
ORDER BY Toplam_Kar DESC;




--BÖLÜM 3: PERFORMANS VE VERÝMLÝLÝK METRÝKLERÝ (KPI & EFFICIENCY METRICS)

-- 1. Verimlilik Analizi: Her kazanýlan 100 TL'nin ne kadarý cepte kalýyor?

SELECT * FROM dbo.Proje_Data

SELECT 
    tarih,
    Faiz_Geliri,
    Faiz_Gideri,

    -- 1. Formül: Net Kazanç (Cebimize kalan)
    (Faiz_Geliri - Faiz_Gideri) AS Net_Faiz_Kazanci,

    -- 2. Formül: Verimlilik Yüzdesi (Kârlýlýk Oraný)
    ((Faiz_Geliri - Faiz_Gideri) / Faiz_Geliri) * 100 AS Verimlilik_Yuzdesi

FROM dbo.Proje_Data
ORDER BY tarih;

-- 2. Kayýp Para Analizi: Faiz kârý ile Net kâr arasýndaki fark (Giderler)
-- Bu fark, bankanýn Risk Karþýlýklarý ve Operasyonel Giderleridir.

SELECT 
    tarih,
    
    -- Senin mantýðýn (Sadece Faize Bakarsak):
    (Faiz_Geliri - Faiz_Gideri) AS Sadece_Faiz_Kari,
    
    -- Gerçek Cepte Kalan:
    Net_Kar,
    
    -- Aradaki Fark Nereye Gitmiþ?
    ((Faiz_Geliri - Faiz_Gideri) - Net_Kar) AS Kayip_Para__Giderler
    
FROM dbo.Proje_Data
ORDER BY tarih;

-- 3. Performans Etiketleme (CASE WHEN Analizi)
-- Aylarý "Mükemmel", "Ortalama" veya "Kötü" olarak sýnýflandýrma.

SELECT * FROM dbo.Proje_Data
SELECT 
    tarih,
    Net_Kar,
    CASE 
        WHEN Net_Kar > 80000 THEN 'Mükemmel'    -- En iyi aylar
        WHEN Net_Kar >= 40000 THEN 'Ortalama'   -- Standart aylar
        ELSE 'Kötü'                             -- 40.000 altý (Alarm!)
    END AS Performans_Durumu
FROM dbo.Proje_Data
ORDER BY Net_Kar DESC;



-- 4. Risk/Kâr Oraný: Her 100 TL kârýn kaç TL'si riske ayrýlýyor?

SELECT 
YEAR(tarih) AS Yýl,
SUM(Kredi_Risk_Karsiligi) AS Toplam_Risk,
SUM(Net_Kar) AS Toplam_Kar,


(SUM(Kredi_Risk_Karsiligi) * 1.0 / SUM(Net_Kar)) * 100 AS Risk_Kar_Orani

FROM dbo.Proje_Data
GROUP BY YEAR(tarih)
ORDER BY YEAR(tarih)

-- 5. Operasyonel Yük Analizi: Diðer risklerin Net Kârýmýza oraný

SELECT * FROM dbo.Proje_Data

SELECT
tarih,
Diger_Riskler,
Net_Kar,
(Diger_Riskler / Net_Kar ) * 100 AS Operasyonel_Yuk_Yuzdesi
FROM dbo.Proje_Data
ORDER BY Operasyonel_Yuk_Yuzdesi DESC;

-- 6. 2024 Ýstikrar (Volatilite) Analizi
SELECT 
    AVG(Faiz_Geliri) AS Ortalama,
    STDEV(Faiz_Geliri) AS Sapma,
    (STDEV(Faiz_Geliri) / AVG(Faiz_Geliri)) * 100 AS Dengesizlik_Yuzdesi
FROM dbo.Proje_Data
WHERE YEAR(tarih) = 2024;




-- BÖLÜM 4: ÝLERÝ ANALÝTÝK VE TREND ANALÝZÝ (ADVANCED ANALYTICS & WINDOW FUNCTIONS)

-- 1. Bir Önceki Aya Göre Deðiþim (LAG)
SELECT 
    tarih,
    Net_Kar AS Bu_Ayki_Kar,
   
    LAG(Net_Kar) OVER(ORDER BY tarih) AS Onceki_Ayki_Kar
    
FROM dbo.Proje_Data
ORDER BY tarih;

-- 2. Aylýk Büyüme Oraný Hesabý ((Yeni - Eski) / Eski * 100) 
SELECT 
    tarih,
    Net_Kar AS Bu_Ayki_Kar,
    LAG(Net_Kar) OVER(ORDER BY tarih) AS Onceki_Ayki_Kar,
    (Net_Kar - LAG(Net_Kar) OVER(ORDER BY tarih))/ LAG(Net_Kar) OVER(ORDER BY tarih) *100  AS Aylýk_Büyüme_Oraný
    
FROM dbo.Proje_Data
ORDER BY tarih;

-- 3. Kümülatif Toplam (Yýl Sonu Birikimi - 2024 Örneði)
SELECT 
    tarih,
    Net_Kar,
    SUM(Net_Kar) OVER(ORDER BY tarih) AS Kumulatif_Toplam_Kar
    
FROM dbo.Proje_Data
WHERE YEAR(tarih) = 2024 
ORDER BY tarih;

-- 4. 3 Aylýk Hareketli Ortalama (Trend Analizi)  (Net Kâr > Hareketli Ortalama ise:YÜKSELÝÞ TRENDÝ)
SELECT 
    tarih,
    Net_Kar,
    
    
    AVG(Net_Kar) OVER(
        ORDER BY tarih 
        ROWS BETWEEN 2 PRECEDING AND CURRENT ROW
    ) AS Hareketli_Ortalama_3Ay
    
FROM dbo.Proje_Data
ORDER BY tarih;

-- 5. Mevsimsellik Analizi (Çeyrek Bazlý)
SELECT 
    DATEPART(QUARTER, tarih) AS Ceyrek, -- 1, 2, 3 veya 4 döner
    COUNT(*) AS Ay_Sayisi,
    
    -- O çeyrekteki Ortalama Kâr
    AVG(Net_Kar) AS Ortalama_Kar,
    
    -- O çeyrekteki Toplam Risk
    SUM(Kredi_Risk_Karsiligi) AS Toplam_Risk,
    
    -- Risk / Kâr Oraný (O çeyrek için)
    (SUM(Kredi_Risk_Karsiligi) / SUM(Net_Kar)) * 100 AS Ceyreklik_Risk_Orani
    
FROM dbo.Proje_Data
GROUP BY DATEPART(QUARTER, tarih)
ORDER BY Ortalama_Kar DESC; -- En kârlý çeyrek en üstte

-- 6. Pareto Analizi (80/20 Kuralý) & Amiral Gemisi Tespiti
WITH Kar_Siralamasi AS (
    SELECT 
        tarih,
        Net_Kar,

        SUM(Net_Kar) OVER(ORDER BY Net_Kar DESC) AS Kumulatif_Kar,
        
        SUM(Net_Kar) OVER() AS Toplam_Kar
        
    FROM dbo.Proje_Data
)
SELECT 
    tarih,
    Net_Kar,
    
    -- Yüzde Kaçlýk Dilimde?
    (Kumulatif_Kar / Toplam_Kar) * 100 AS Kar_Katlisi_Yuzdesi,
    
    -- ETÝKETLEME: %80'i oluþturanlara "Amiral Gemisi" diyoruz.
    CASE 
        WHEN (Kumulatif_Kar / Toplam_Kar) * 100 <= 80 THEN 'A Sýnýfý (Amiral Gemisi)'
        ELSE 'B Sýnýfý (Standart)'
    END AS Pareto_Sinifi
    
FROM Kar_Siralamasi
ORDER BY Net_Kar DESC;




-- BÖLÜM 5: RAPORLAMA VE ÝÞ ZEKASI KATMANI (POWER BI VIEWS)

-- 1. Yýllýk Özet View
GO
CREATE VIEW View_YillikOzet AS  
SELECT 
    YEAR(tarih) AS Yil, 
    SUM(Net_Kar) AS Toplam_Kar
FROM dbo.Proje_Data
GROUP BY YEAR(tarih);
GO
SELECT * FROM View_YillikOzet;
SELECT * FROM View_YillikOzet ORDER BY Yil;


-- 2. Basit Finansal Özet View
GO
CREATE VIEW View_Banka_Finansal_Ozet AS
SELECT 
    tarih,
    YEAR(tarih) AS Yil,
    DATENAME(MONTH, tarih) AS Ay,
    Net_Kar,
    Faiz_Geliri,
    (Net_Kar / NULLIF(Faiz_Geliri, 0)) * 100 AS Net_Kar_Marji
FROM dbo.Proje_Data;
GO
SELECT TOP 10 * FROM View_Banka_Finansal_Ozet;

-- 3. Master Analitik View (Ana Tablo)
GO
CREATE VIEW View_Banka_Analitik_Master AS
WITH Hesaplamalar AS (
    SELECT 
        *,
        -- 1. Bir Önceki Ayýn Kârý (Büyüme hesabý için)
        LAG(Net_Kar) OVER(ORDER BY tarih) AS Onceki_Ay_Kar,

        -- 2. 3 Aylýk Hareketli Ortalama (Trend Grafiði için)
        AVG(Net_Kar) OVER(ORDER BY tarih ROWS BETWEEN 2 PRECEDING AND CURRENT ROW) AS Hareketli_Ortalama_3Ay,

        -- 3. Pareto Ýçin Hazýrlýk (Kâr Sýralamasý ve Toplam)
        SUM(Net_Kar) OVER(ORDER BY Net_Kar DESC) AS Kumulatif_Kar_Pareto,
        SUM(Net_Kar) OVER() AS Toplam_Yillik_Kar
    FROM dbo.Proje_Data
)
SELECT 
    tarih,
    YEAR(tarih) AS Yil,
    DATENAME(MONTH, tarih) AS Ay_Adi,
    Net_Kar,
    Diger_Riskler,
    Hareketli_Ortalama_3Ay,
    
    -- Hesaplanan Metrikler --
    
    -- A) Büyüme Oraný (%)
    CASE 
        WHEN Onceki_Ay_Kar IS NULL THEN 0 
        ELSE ((Net_Kar - Onceki_Ay_Kar) / Onceki_Ay_Kar) * 100 
    END AS Buyume_Orani,

    -- B) Operasyonel Yük (%)
    (Diger_Riskler / NULLIF(Net_Kar, 0)) * 100 AS Operasyonel_Yuk,

    -- C) Pareto Sýnýfý (A / B)
    CASE 
        WHEN (Kumulatif_Kar_Pareto / NULLIF(Toplam_Yillik_Kar,0)) * 100 <= 80 THEN 'A Sýnýfý (Yýldýz Ay)'
        ELSE 'B Sýnýfý (Standart)'
    END AS Pareto_Sinifi

FROM Hesaplamalar;
GO
SELECT * FROM View_Banka_Analitik_Master;

-- 4. Çeyreklik Özet View
GO
CREATE VIEW View_Banka_Ceyreklik_Ozet AS
SELECT 
    DATEPART(YEAR, tarih) AS Yil,
    DATEPART(QUARTER, tarih) AS Ceyrek, -- Q1, Q2...
    COUNT(*) AS Ay_Sayisi,
    AVG(Net_Kar) AS Ortalama_Kar,
    SUM(Kredi_Risk_Karsiligi) AS Toplam_Risk,
    -- Risk Oraný
    (SUM(Kredi_Risk_Karsiligi) / NULLIF(SUM(Net_Kar),0)) * 100 AS Risk_Kar_Orani
FROM dbo.Proje_Data
GROUP BY DATEPART(YEAR, tarih), DATEPART(QUARTER, tarih);
GO
SELECT * FROM View_Banka_Ceyreklik_Ozet;
