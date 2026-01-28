
# 🏦 BDDK Verileriyle Türk Bankacılık Sektörü Finansal Analiz Hattı (End-to-End Pipeline)

Bu proje; BDDK tarafından yayımlanan aylık banka finansal verilerini alıp, analitik olarak “ham ve dağınık” olan bu verileri **SQL & Power BI** ortamında doğrudan kullanılabilir, karşılaştırılabilir ve karar destek üretebilir bir finansal veri setine dönüştüren uçtan uca bir **Data Pipeline** çalışmasıdır.

<img width="1303" height="730" alt="image" src="https://github.com/user-attachments/assets/48f98d25-f81a-496d-b0ee-a4839916a3fc" />
<img width="1281" height="717" alt="image" src="https://github.com/user-attachments/assets/f7ae555a-8638-41cb-841e-17ae8f458ff0" />


---

## 🔍 Proje Ne Yapıyor? 
Proje, sadece görselleştirme yapmanın ötesinde, veriyi rapora hazır hale getiren analitik bir altyapı sunar. 

---

### 🔹 Adım Adım Veri Yolculuğu
1. **Ham Regülasyon Verisinin Alınması:** Analiz için doğrudan uygun olmayan, farklı formatlardaki BDDK mizan Excel dosyaları sürece dahil edilir.
2. **Verinin Analiz Edilebilir Hale Getirilmesi:** - **Sınıflandırma:** Finansal kalemler (gelir, gider, risk, operasyonel) yeniden kategorize edilir.
   - **Konsolidasyon:** Tüm veriler, Power BI ve SQL için **"Single Source of Truth"** (Tek Doğru Kaynak) olan `Proje_Final_Master_Data.xlsx` altında birleştirilir.
3. **SQL Katmanında "Anlam" Üretimi:** - Hesaplama yükü rapor seviyesinden veritabanı seviyesine çekilerek **Reporting Views** oluşturulur. (İyi bir BI mimarisi için hesaplamalar SQL'de yapılır).
   - Büyüme oranları, dönemsel karşılaştırmalar ve Pareto (80/20) analizleri T-SQL ile hesaplanır.
4. **Power BI Karar Destek Çıktısı:** KPI'lar ve trend analizleri ile "Bankanın bu ayki performansı ne söylüyor?" sorusuna yanıt üretilir.

---

## 🛠 Teknik Yetenekler (Technical Stack)

| Aşama | Kullanılan Araçlar | Uygulanan Teknikler |
| :--- | :--- | :--- |
| **ETL (Veri İşleme)** | Python (Pandas) | Regex ile dosya ayıklama, Glob otomasyonu, Veri temizleme. |
| **İleri Analitik** | SQL Server (T-SQL) | Window Functions, **Reporting Views (BI Entegrasyonu)**, Pareto Analizi. |
| **Görselleştirme** | Power BI | Dinamik KPI Dashboards, Trend Takibi, Hareketli Ortalamalar. |

---

## 🚀 Kullanım Rehberi (Tak-Çalıştır / Plug-and-Play)

Bu proje, karmaşık kurulum ve yapılandırma süreçlerini ortadan kaldıran **"Plug-and-Play"** mimarisiyle tasarlanmıştır.

1.  **Veri Hazırlığı ve Yerleşimi:** Analizde kullanılan **ham BDDK mizan verileri, notebook dosyalarıyla aynı dizinde hazır olarak sunulmuştur.** Ayrıca kendi verilerinizi eklemek isterseniz, Excel dosyalarını ana dizine kopyalamanız yeterlidir.
    * **Kritik Not:** Kod yapısı `path = "."` (mevcut dizin) olarak kurgulandığı için veriler ve notebooklar aynı klasörde olduğu sürece sistem dosyaları otomatik olarak tanır. Ek bir dosya yolu düzenlemesine gerek kalmadan analizler doğrudan başlatılabilir.
2.  **Python ETL Süreci:** `faz1.ipynb` dosyasından başlayarak sırasıyla notebook'ları çalıştırın. Bu otomasyon süreci sonunda tüm verileriniz konsolide edilerek `Proje_Final_Master_Data.xlsx` dosyanız otomatik olarak oluşturulacaktır.
3.  **SQL Analitik Katmanı:** Oluşan master veriyi SQL Server tablonuza aktarın ve `Banka_Finansal_Analiz_Projesi.sql` script'ini çalıştırın. 
    * **Reporting Views:** SQL içerisinde Power BI için optimize edilmiş özel görünümler (Views) oluşturulur. Bu sayede hesaplama yükü veritabanı seviyesinde tutularak rapor performansı maksimize edilir.
4.  **Power BI Dashboard:** `BANKA PROJESİ RAPORU.pbix` dosyasını açarak SQL veritabanınıza bağlayın. Tüm hesaplanan metrikler dashboard üzerinde anlık olarak güncellenecektir.

---

## 📂 Proje Hiyerarşisi
* **`/Notebooks`**: Veri temizleme, sınıflandırma ve analitik dönüşüm süreçleri (`faz1.ipynb`, `faz2.ipynb`, `faz3.ipynb`, `merge.ipynb`).
* **`/SQL`**: Analitik sorgular ve **Power BI Reporting Views** (`Banka_Finansal_Analiz_Projesi.sql`).
* **`/Reports`**: Karar vericiler için hazırlanan interaktif dashboard (`BANKA PROJESİ RAPORU.pbix`).
* **`Proje_Final_Master_Data.xlsx`**: Tüm süreçlerin sonunda oluşan, analize hazır nihai veri seti.



---

## 📈 Öne Çıkan Analitik Göstergeler
1. **Net Faiz Marjı (NIM):** Aylık faiz gelir/gider dengesinin takibi.
2. **Operasyonel Yük Analizi:** Diğer risklerin kârlılık üzerindeki baskısının ölçülmesi.
3. **Pareto (80/20) Sınıflandırması:** Toplam kârın %80'ini getiren "Yıldız Ay"ların SQL ile tespiti.
4. **3 Aylık Hareketli Ortalama:** Mevsimsellikten arındırılmış finansal trend takibi.

---

### Projenin Konumlandırılması
Bu proje, manuel finansal raporlama süreçlerini otomatikleştirmeyi hedefleyen ve uçtan uca analitik düşünceyi yansıtan bir portföy çalışmasıdır.

