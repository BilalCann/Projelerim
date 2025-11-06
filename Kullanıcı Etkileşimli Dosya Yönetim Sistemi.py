DOSYA = "kisiler.txt"
ADET= 25
kayitlar = []

print("1- 25 kişi verisi gir.")
print("2- Sadece sorgu yap.")
ilkSecim= input("Seçiminiz: ").strip()

if ilkSecim=="1":
    print("\n Kişi kayıt programı ({} kişi)".format(ADET))
    sayac=0
    while sayac < ADET:
        print("\n {}. Kayıt ".format(sayac+1))
        ad= input("Adı: ").strip().title()
        soyad= input("Soyadı: ").strip().title()

        while True:
            tel= input("Telefon: (05XXXXXXXXX):").strip()
            if tel.isdigit() and len(tel)==11 and tel.startswith("05"):
                break
            print("HATA! 05 ile başlayan 11 haneli sayı giriniz.")

        while True:
            dy= input("Doğum yeri: ").strip().title()
            if dy.replace(" ","").isalpha():
                break
            print("HATA! Sadece harf kullanınız.")

        kayitlar.append([ad, soyad, tel, dy])
        sayac+=1
        print("Kayıt eklendi.")

    f=open(DOSYA, "w", encoding="utf-8")
    for k in kayitlar:
        f.write(k[0] + ";" + k[1] + ";" + k[2] + ";" + k[3] + ";" + "\n")
    f.close()
    print("\n Tüm kayıtlar \"{}\" dosyasına kaydedildi".format(DOSYA))

if ilkSecim=="2" or ilkSecim=="1":
    f=open(DOSYA, "w", encoding="utf-8")
    satirlar = f.read().splitlines()
    f.close()

    kayitlar = []
    for s in satirlar:
        parcala= s.split(";")
        if len(parcala)==4:
            kayitlar.append(parcala)

    print("\n{} Sorgu menüsüne geçiliyor.".format(len(kayitlar)))

    while True:
        print("\n Sorgu seçenekleri")
        print("1- Ad sorgusu")
        print("2- Soyad sorgusu")
        print("3- Telefon sorgusu")
        print("4- Doğum yeri sorgusu")
        print("5- Çıkış")
        secim= input("Seciminiz: ").strip()

        if secim=="0":
            print("Program sonlandırıldı.")
            break

        ifade= input("Aranan ifadeyi giriniz: ").strip().title()
        sonuc= []

        for ad, soyad, tel, dy in kayitlar:
            if secim=="1" and ifade in ad:
                sonuc.append([ad, soyad, tel, dy])
            elif secim=="2" and ifade in soyad:
                sonuc.append([ad, soyad, tel, dy])
            elif secim=="3" and ifade in tel:
                sonuc.append([ad, soyad, tel, dy])
            elif secim=="4" and ifade in tel:
                sonuc.append([ad, soyad, tel, dy])

        print("\n {} kayıt bulundu".format(len(sonuc)))
        for k in sonuc:
            print("{:<12} {:<12} {} {}".format(k[0], k[1], k[2], k[3]))

        devam= input("\n Yeni sorgu için (E), çıkış için başka tuşa basınız.").lower()
        if devam !="e":
            print("Program sonlandırıldı.")
            break

else:
    print("Geçerli seçim yapınız.")
