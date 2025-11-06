import os

def haberOrtalamalariVeKaydetme(klasor, yeniKlasor):
    haberDilleri = {
        'Almanca': [],
        'İngilizce': [],
        'Türkçe': [],
        'İspanyolca': [],
    }

    for dosya in os.listdir(klasor):
        if dosya.startswith('ALMANCA'):
            haberDilleri['Almanca'].append(dosya)
        elif dosya.startswith('INGILIZCE'):
            haberDilleri['İngilizce'].append(dosya)
        elif dosya.startswith('TURKCE'):
            haberDilleri['Türkçe'].append(dosya)
        elif dosya.startswith('ISPANYOLCA'):
            haberDilleri['İspanyolca'].append(dosya)

    ortalamalar = {}

    for dil, dosyalar in haberDilleri.items():
        toplamKarakter = 0
        toplamKelime = 0
        toplamCumle = 0
        toplamIcerik = ''

        for dosya in dosyalar:
            yol = os.path.join(klasor, dosya)
            with open(yol, 'r', encoding='utf-8') as f:
                icerik = f.read()
                toplamIcerik += icerik + '\n'
                toplamKarakter += len(icerik)
                toplamKelime += len(icerik.split())
                toplamCumle += icerik.count('.') + icerik.count('!') + icerik.count('?')

        if len(dosyalar) > 0:
            ortalamaKarakter = toplamKarakter / len(dosyalar)
            ortalamaKelime = toplamKelime / len(dosyalar)
            ortalamaCumle = toplamCumle / len(dosyalar)
            ortalamalar[dil] = {
                'Ortalama Karakter': ortalamaKarakter,
                'Ortalama Kelime': ortalamaKelime,
                'Ortalama Cümle': ortalamaCumle
            }

            hedef_yol = os.path.join(yeniKlasor, f'{dil}.txt')
            with open(hedef_yol, 'w', encoding='utf-8') as f:
                f.write(toplamIcerik)
            print(f'{dil} diline ait dosyalar {hedef_yol} adresinde birleştirildi.')
        else:
            ortalamalar[dil] = {
                'Ortalama Karakter': 0,
                'Ortalama Kelime': 0,
                'Ortalama Cümle': 0
            }

    print("{:<12} {:<20} {:<20} {:<20}".format('Dil', 'Ort. Karakter', 'Ort. Kelime', 'Ort. Cümle'))
    for dil, ist in ortalamalar.items():
        print("{:<12} {:<20} {:<20} {:<20}".format(
            dil, round(ist['Ortalama Karakter'], 2),
            round(ist['Ortalama Kelime'], 2), round(ist['Ortalama Cümle'], 2)
        ))

klasor = r"C:\Users\bilal\OneDrive\Masaüstü\archive\Texts\Texts"
yeniKlasor = r"C:\Users\bilal\OneDrive\Masaüstü\Haberler"
haberOrtalamalariVeKaydetme(klasor, yeniKlasor)

