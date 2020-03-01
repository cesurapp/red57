# red57 Virus

Delphi 7 ile yazılmıştır ve bağımlılığı yoktur. **Botnet**, **Trojan**, **Keylogger**, **CPU Miner**, **Autorun.inf** gibi özelliklere sahiptir. 10 yıldan fazla sürede boş vakitlerimde hobi olarak geliştirdim. **.Exe**, **.Excel**, **.Doc files** uzantılı dosyalara bulaşabilir.

---

**UYARI:** BU KODLAR SADECE EĞİTİM AMAÇLI PAYLAŞILIR. SORUMLULUK KABUL ETMİYORUM.

**UYARI:** KENDİ BİLGİSAYARINIZDA ÇALIŞTIRMAYIN. TÜM DOSYALARI ETKİLER.

**UYARI:** YAZILIM DAHA FAZLA GELİŞTİRİLMEMEKTEDİR.

---

![server](https://raw.githubusercontent.com/appaydin/red57/master/Screenshoot/app-server.png)
![projeclient](https://raw.githubusercontent.com/appaydin/red57/master/Screenshoot/project-client.png)
![projeserver](https://raw.githubusercontent.com/appaydin/red57/master/Screenshoot/project-server.png)

---

**Gereksinimler**
- Delphi7 

---

**Detaylar ve Kullanım**

- Uzak bağlantı için modem üzerinden bağlantı portunuzu sunucunun (Server) çalıştığı makinaya yönlendirmeniz gerekir. 
- Client'in Server'a bağlanması için IP adreslerinin aynı olması gerekir. Client hiçbir şekilde ekranda çalıştığına dair bir form görüntülemez. Arka planda çalışması ise yaklaşık 3-5 dakikayı bulabilir.
- Botnet clienti 127.0.0.1 ip adresine ayarlanmıştır. ``Client\Main.pas:63`` satırdan değiştirebilirsiniz. Sunucuya bağlanması yaklaşık 3 dakika sürmektedir. Antivirüslerden kaçınmak için sistem bir süre arkaplanda hiçbir işlem yapmadan bekler.
- Client XP üzerinde admin olarak çalışır. İşletim sistemi zaten pek güvenli değil :)
- Win7 ve Win10 üzerinde admin olarak başlangıçta çalışmak için msconfig yada Zamanlanmış Görevleri kullanır.
- Flashdisk ve Harici disklerdeki dosya değişikliklerini izler ve bulaşabileceği dosyalara bulaşır. Sistemi gereksiz yormaz. 
- Masaüstü, belgelerim, Flashdisk, Harici Disk gibi bölümlere ara ara genel tarama yapıp bulaşmaya çalışır. 
- Excel, Word dosyalarına VB6 Macro kodu ekler ve bu şekilde kendini bulaştırmaya çalışır. Kullanıcının başlangıçta makroyu etkinleştirmesi için sayfaları gizleyerek kullanıcıyı zorlar. Word, Excel dosyalarına bulaşması için makinada office yazılımlarının kurulu olması gerekir, yoksa bulaşmaz.
- Kodlardaki tüm Stringler (Yazılar) Xor Encoder ile şifrelenmiştir. Buradaki amaç antivirüslerin bellekteki stringleri analiz etmesini engellemektir. (Metod isimleride aynı şekilde anlamsız olarak isimlendirildi)
- Bazı windows apileri genel olarak kötüye kullanıdığından dolayı ve bunları kullanmam gerektiği için bu apileri dinamik olarak şifrelenmiş şekilde kullandım. uKbrdDl.pas - uWin.pas dosyasını incelersiniz.
- Tüm şifrelemeler uEnc.pas dosyası üzerinden yapılır.
- Client'in başlangıçta çalışması için gereken tüm işlemleri uAI.pas dosyası yapar. Bu bölüm için farklı düşüncelerim olsada Delphi7 ile anca bu kadar :)
- Keylogger klavye vuruşlarını kaydeder. Windows API'si kullanılıyor ve birçok antivirüs tarafından fişlenmiş durumda. Gizlemek için çok uğraştım ama bazı antivirüsler bellek üzerinde ara ara tarama yaptıkları için tamamından gizlemek zor.
- Botnet ile Client üzerinde şu işlemler yapılabilir: Ekran resmi almak, CMD erişimi, Dosya yöneticisi, Miner, Sistem bilgisi, Kes-Kopyala-Yapıştır vs.
- Botnet için önceleri "Delphi Indy9" kullanılırken bu sürümde Windows API'si kullanılmıştır. Kullanılan apiler ve protokoller eski olduğundan dolayı antivirüsler kolayca yakalayabiliyor.

Kendi makinanızda çalıştırmayın. Virtualbox ile sanal sunucu kurup deneyin. Bulaşan dosyaları eski haline getirmek gibi bir fantaziye girmedim sonra başınız ağrımasın.

Son olarak tamamen bir zevk ürünüdür, hiçbir art niyet barındırmamaktadır. Lise yıllarında başlayıp ara ara geliştirmem ile ortaya çıkmıştır. 
