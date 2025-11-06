create DATABASE OTOMOTIVS;
GO

USE OTOMOTIVS

--Tablolar

create table YakýtVeEnerjiTurleri(
	YakitTuruID INT PRIMARY KEY IDENTITY(1,1),
	YakýtTuruAdi Varchar(30) not null,
	Aciklama varchar(200) 
);

create table AracTurleri(
	AracTuruID INT PRIMARY KEY IDENTITY(1,1),
	AracTuruAdi varchar(20) not null
);

create table Tedarikciler (
	TedarikciID INT PRIMARY KEY IDENTITY(1,1),
	TedarikciAdi varchar (30) not null,
	Telefon varchar(20) not null,
	EMail varchar(50),
	Adres varchar(100)
);

create table Arabalar(
	ArabaID INT PRIMARY KEY IDENTITY(1,1),
	Marka varchar(30) not null,
	Model varchar (30) not null,
	Yil int not null,
	Fiyat decimal(12,2) not null,
	Renk varchar(30) default'Bilinmiyor',
	YakitTuruID INT NOT NULL,
	AracTuruID INT NOT NULL,
	Durum bit not null default 0,
	foreign key (YakitTuruID) references YakýtVeEnerjiTurleri (YakitTuruID),
	foreign key (AracTuruID) REFERENCES AracTurleri (AracTuruID)
);

CREATE TABLE Musteriler(
	MusteriID INT PRIMARY KEY IDENTITY(1,1),
	Ad varchar(30) not null,
	Soyad varchar (30) not null,
	EMail varchar(50) not null unique,
	Telefon varchar(15) not null unique,
	Sehir varchar(13),
	Ilce varchar(30),
	DogumTarihi date
);

create table Personeller(
	PersonelID INT PRIMARY KEY IDENTITY(1,1),
	Ad varchar(30) not null,
	Soyad varchar (30) not null,
	EMail varchar(50) not null unique,
	Telefon varchar(15) not null unique,
	Pozisyon varchar(30) not null,
	IseBaslamaTarihi date not null,
	Maas decimal (10,2) not null
);

create table YedekParcalar(
	YedekParcaID INT PRIMARY KEY IDENTITY(1,1),
	ParcaAdi varchar(30) not null,
	Marka varchar(30) not null,
	Fiyat decimal(10,2) not null,
	TedarikciID INT NOT NULL,
	FOREIGN KEY (TedarikciID) REFERENCES Tedarikciler (TedarikciID)
);

CREATE TABLE Sigortalar(
	SigortaID INT PRIMARY KEY IDENTITY(1,1),
	ArabaID INT NOT NULL,
	SigortaTuru varchar(30) not null,
	SigortaSirketi varchar(30) not null,
	BaslangicTarihi date not null,
	BitisTarihi date not null,
	PrimTutari decimal(10,2) not null,
	Foreign key (ArabaID) REFERENCES Arabalar(ArabaID)
);

create table Satislar(
	SatisID INT PRIMARY KEY IDENTITY(1,1),
	MusteriID INT  NOT NULL,
	ArabaID INT  NOT NULL,
	SatisTarihi date not null,
	SatisTutari decimal(10,0) not null,
	OdemeYontemi varchar(20),
	PersonelID INT NOT NULL,
	Foreign key (MusteriID) REFERENCES Musteriler(MusteriID),
	FOREIGN KEY (ArabaID) REFERENCES Arabalar(ArabaID),
	foreign key (PersonelID) REFERENCES Personeller(PersonelID)
);

CREATE TABLE ArabaStoklari(
	StokID INT PRIMARY KEY IDENTITY(1,1),
	ArabaID INT NOT NULL,
	StokAdedi int not null,
	FOREIGN KEY (ArabaID) REFERENCES Arabalar(ArabaID)
);

CREATE TABLE YedekParcaStoklari(
	StokID INT PRIMARY KEY IDENTITY(1,1),
	YedekParcaID INT NOT NULL,
	StokAdedi int not null,
	FOREIGN KEY (YedekParcaID) REFERENCES YedekParcalar(YedekParcaID)
);

-----------Indexler
Create INDEX IX_Arabalar_Marka_Model on Arabalar(Marka, Model); 


create index IX_Satislar_MusteriID ON Satislar(MusteriID);
create index IX_Satislar_ArabaID ON Satislar(ArabaID);
create index IX_Satislar_PersonelID ON Satislar(PersonelID);


CREATE INDEX IX_YedekParcalar_ParcaAdi_Marka on YedekParcalar(ParcaAdi, Marka);


CREATE INDEX IX_ArabaStoklari_ArabaID ON ArabaStoklari (ArabaID);


CREATE INDEX IX_YedekParcaStoklari_YedekParcaID ON YedekParcaStoklari(YedekParcaID);

-----------------VIEWLER

CREATE VIEW vw_StokDurumu as
select
	'Araba' as UrunTuru,
	A.Marka + ' ' + A.Model as UrunAdi,
	S.StokAdedi
From
	ArabaStoklari S
JOIN Arabalar A ON S.ArabaID = A.ArabaID
union all
select
	'Yedek Parça' as UrunTuru,
	Y.ParcaAdi as UrunTuru,
	S.StokAdedi
from YedekParcaStoklari S
JOIN YedekParcalar Y ON S.YedekParcaID = Y.YedekParcaID;


create view vw_MusteriSatislar as
select
	M.Ad+ ' ' +M.Soyad as MusteriAdi,
	A.Marka+ ' ' +A.Model as Arac,
	S.SatisTarihi,
	S.SatisTutari
from Satislar S
JOIN Musteriler M ON S.MusteriID= M.MusteriID
join Arabalar A ON S.ArabaID= A.ArabaID ;


CREATE VIEW vw_PersonelSatisPerformansi as
select
	P.Ad+ ' ' + P.Soyad as PersonelAdi,
	count(S.SatisID) AS ToplamSatis,
	sum(S.SatisTutari) as ToplamCiro
from Satislar S
JOIN Personeller P on S.PersonelID= P.PersonelID
GROUP BY P.Ad, P.Soyad;


CREATE VIEW vw_ArabaSigortaDurumu as 
select
	A.Marka+ ' '+ A.Model as Arac,
	S.SigortaTuru,
	S.SigortaSirketi,
	S.BaslangicTarihi,
	S.BitisTarihi
from Sigortalar S
JOIN Arabalar A ON S.ArabaID= A.ArabaID
WHERE S.BitisTarihi>=GETDATE();


CREATE VIEW vw_SatisDetaylari as
SELECT
	S.SatisID,
	M.Ad+ ' '+ M.Soyad as MusteriAdi,
	A.Marka+ ' '+ A.Model as Arac,
	P.Ad+ ' '+ P.Soyad as PersonelAdi,
	S.SatisTarihi,
	S.SatisTutari,
	S.OdemeYontemi
from Satislar S
JOIN Musteriler M ON S.MusteriID= M.MusteriID
JOIN Arabalar A ON S.ArabaID= A.ArabaID
JOIN Personeller P ON S.PersonelID= P.PersonelID;


-----------------------VERÝ GÝRÝÞLERÝ

INSERT INTO YakýtVeEnerjiTurleri (YakýtTuruAdi,Aciklama)
values
('Benzin', 'Normal benzin'),
('Motorin', 'Normal dizel'),
('LPG', 'Hem benzin hem gaz'),
('Hybrid', 'Hem benzin hem elektrik'),
('Elektrik', 'Normal elektrik');

insert into AracTurleri(AracTuruAdi)
values
('Sedan'),
('Hatchback'),
('Stationwagon'),
('SUV'),
('Ticari');


insert into Tedarikciler(TedarikciAdi, Telefon, EMail, Adres)
values
('Nilüfer Oto', '05335535656', 'nilüferoto@gmail.com', 'Bursa,Türkiye'),
('Öznur Otomotiv', '05656878953', 'öznurotomotiv@outlook.com', 'Bursa, Türkiye'),
('Neskar', '05123456789', 'neskar@yahoo.com', 'Bursa, Türkiye'),
('Japon Otomotiv', '05347895623', 'japonoto@gmail.com', 'Bursa, Türkiye'),
('Opel', '074512356920', 'opeldeutche@gmail.com', 'Köln, Almanya'),
('Opel', '09852315467', 'opelpolska@gmail.com', 'Warsava, Polonya');


insert into Arabalar(Marka, Model, Yil, Fiyat, Renk, YakitTuruID,AracTuruID, Durum)
values
('Opel', 'Ýnsignia', 2024, 1500000, 'Beyaz', 1, 1, 0),
('Opel', 'Ýnsignia', 2024, 1600000, 'Siyah', 2, 1, 0),
('Opel', 'Ýnsignia', 2023, 1500000, 'Kýrmýzý', 1, 1, 0),
('Opel', 'Ýnsignia', 2024, 1750000, 'Beyaz', 2, 3, 0),
('Opel', 'Astra', 2024, 1200000, 'Siyah', 1, 3, 0),
('Opel', 'Astra', 2024, 1250000, 'Sarý', 2, 3, 0),
('Opel', 'GrandlandX', 2024, 1750000, 'Mavi', 1, 4, 0),
('Renault', 'Megane', 2023, 2240000, 'Beyaz', 4, 5, 0),
('Toyota', 'Auris', 2018, 950000, 'Beyaz', 2, 2, 0);

insert into Musteriler(Ad, Soyad, Telefon, EMail, Sehir, Ilce, DogumTarihi)
values
('Bilal', 'Can', '05333336762','bilal4can@gmail.com', 'Bursa', 'Osmangazi', '2003-08-24'),
('Onur', 'Þimþek', '05125456789','onursi4m@gmail.com', 'Bursa', 'Orhangazi', '1998-09-09'),
('Zeynep', 'Aydýn', '05472245689','zeynepaydin@outlook.com', 'Bursa', 'Kestel', '1989-05-17'),
('Hasan', 'Gonca', '05496785319','hasangoncaa@yahoo.com', 'Bursa', 'Gürsu', '1979-05-30'),
('Ali', 'Veli', '05193456785','aliveli4950@hotmail.com', 'Bursa', 'Yýldýrým', '1995-02-25'),
('Eymen', 'Atar', '0545612356','eymenatar16@gmail.com', 'Bursa', 'Nilüfer', '1963-01-06');

insert into Personeller(Ad, Soyad, Telefon, EMail, Pozisyon, Maas, IseBaslamaTarihi)
values
('Nurþen', 'Kaya', '0567953257', 'nursen123245@gmail.com', 'Bakým Uzmaný', 34000, '2000-01-01'),
('Ali', 'Can', '05642351425', 'ali458@gmail.com', 'Sigorta Danýþmaný', 42044, '2017-05-12'),
('Ayþe', 'Nurlu', '0224563157', 'ayseeenurluu@gmail.com', 'Yönetici', 114000, '2022-08-11'),
('Ahmet', 'Kaya', '5431112233', 'ahmetkaya@gmail.com', 'Satýþ Danýþmaný', 7000, '2020-01-15'),
('Fatih', 'Aslan', '05412378564', 'fatiaslann@outlook.com', 'Muhasebe', 26500, '2022-05-10');

insert into YedekParcalar(ParcaAdi, Marka, Fiyat, TedarikciID)
values
('Fren Disk', 'Bosch', 12500, 1),
('Buji', 'MANN', 2290, 2),
('Hava Filtresi', 'Opel', 1450, 5),
('Þanzýman Yaðý', 'Castroll', 600, 3),
('Sandýk Motor', 'Opel', 120000, 4);

insert into Sigortalar(ArabaID, SigortaTuru, SigortaSirketi, BaslangicTarihi, BitisTarihi, PrimTutari)
values
(1, 'Kasko', 'Allianz', '2022-05-06', '2024-05-06', 23000),
(2, 'Zorunlu Trafik', 'AXA', '2023-02-10', '2024-02-10', 9000),
(3, 'Zorunlu Trafik', 'Hayat', '2024-01-01', '2025-01-01', 12000 ),
(4, 'Kasko', 'AXA', '2023-10-10', '2025-10-10', 21000),
(5, 'Kasko', 'Garanti', '2021-12-12', '2024-12-12', 27000);

insert into Satislar(MusteriID, ArabaID, SatisTarihi, SatisTutari, OdemeYontemi, PersonelID)
values
(1, 5, '2024-12-12', 2000000, 'Nakit', 1),
(2, 4, '2023-01-12', 1800000, 'Çek', 3),
(3, 3, '2024-02-25', 1000000, 'Nakit',4),
(4, 2, '2024-12-01', 1300000, 'Kredi Kartý', 5),
(5, 1, '2023-12-12', 1700000, 'Nakit', 2);

insert into ArabaStoklari(ArabaID, StokAdedi)
values
(1, 3),
(2,4),
(5,1),
(4,3),
(3,2);

insert into YedekParcaStoklari(YedekParcaID, StokAdedi)
values
(2,9),
(3, 10),
(1, 2),
(4, 34),
(5,2);



---- Oluþturmuþ olduðunuz veritabanýnda esnafýn günlük karlarýný nasýl listeleyeceðini gösteren sorguyu yazýnýz.

select 
	cast (S.SatisTarihi AS DATE) AS Gun,
	sum(S.SatisTutari - A.Fiyat) as GunlukKar
from Satislar S
JOIN Arabalar A ON S.ArabaID= A.ArabaID
GROUP BY CAST (S.SatisTarihi AS DATE)
ORDER BY Gun ASC;

--Oluþturmuþ olduðunuz veritabanýnda esnafýn ortalama aylýk karlarýný belirleyin. Bu deðerin 
--altýndaki aylara ait satýþlarý nasýl listeleyeceðini gösteren sorguyu yazýnýz.

with AylikKar as(
	select
		format(S.SatisTarihi, 'yyyy-MM') AS Ay,
		Sum(S.SatisTutari - A.Fiyat) as AylikKar
	from Satislar S
	JOIN Arabalar A ON S.ArabaID= A.ArabaID
	GROUP BY FORMAT(S.SatisTarihi, 'yyyy-MM')
),
OrtalamaKar AS (
	SELECT AVG(AylikKar) as OrtalamaKar FROM AylikKar
)
select
	AylikKar.Ay,
	S.SatisID,
	S.SatisTarihi,
	S.SatisTutari,
	A.Marka, ' ', A.Model as Arac
from Satislar S
JOIN Arabalar A ON S.ArabaID = A.ArabaID
JOIN 
	AylikKar on format(S.SatisTarihi, 'yyyy-MM') = AylikKar.Ay
cross join OrtalamaKar
where
	AylikKar.AylikKar < OrtalamaKar.OrtalamaKar
order by
	AylikKar.Ay asc;

--Oluþturmuþ olduðunuz veritabanýnda esnafýn en çok hangi ürünü sattýðýný listeleyeceðini gösteren sorguyu yazýnýz. 

WITH SatisSayisi AS (
	SELECT
		CASE
			WHEN S.ArabaID IS NOT NULL THEN A.Marka + ' ' + A.Model
			ELSE Y.ParcaAdi
		END AS UrunAdi,
		COUNT(*) AS SatisSayisi
	FROM Satislar S
	LEFT JOIN Arabalar A ON S.ArabaID = A.ArabaID
	LEFT JOIN YedekParcalar Y ON S.ArabaID IS NULL AND Y.YedekParcaID = S.ArabaID
	GROUP BY
		CASE
			WHEN S.ArabaID IS NOT NULL THEN A.Marka + ' ' + A.Model
			ELSE Y.ParcaAdi
		END
)
SELECT TOP 1
	UrunAdi,
	SatisSayisi
FROM SatisSayisi
ORDER BY SatisSayisi DESC;


--Oluþturmuþ olduðunuz veritabanýnda esnafýn zarar ettiði ürünleri nasýl listeleyeceðini gösteren sorguyu yazýnýz. 

select
	S.SatisID,
	S.SatisTarihi,
	case
		when S.ArabaID IS NOT NULL THEN A.Marka+ ' ' + A.Model
		else Y.ParcaAdi
	end as UrunAdi,
	case
		when S.ArabaID IS NOT NULL THEN A.Fiyat - S.SatisTutari
		else Y.Fiyat - S.SatisTutari
	end as Zarar
from Satislar S
left join Arabalar A ON S.ArabaID= S.ArabaID
LEFT JOIN YedekParcalar Y ON S.ArabaID IS NULL AND Y.YedekParcaID = S.ArabaID
WHERE 
	(S.ArabaID IS NOT NULL AND S.SatisTutari < A.Fiyat)
	or (S.ArabaID IS NULL AND S.SatisTutari < Y.Fiyat);

--------------------------PROSEDÜRLER

--1-Günlük Karlarý Listeleme
create procedure sp_GunlukKar
as
begin
	SELECT 
		CAST(S.SatisTarihi as date) as Gun,
		sum(S.SatisTutari - A.Fiyat) asGunlukKar
	from Satislar S
	JOIN Arabalar A ON S.ArabaID=A.ArabaID
	GROUP BY 
		CAST(S.SatisTarihi as date)
	order by
		Gun asc;
end;

exec sp_GunlukKar;


--2-Ortalama Altýnda Kalan Aylýk Satýþlar
create procedure sp_OrtalamaAltindakiSatislar
as
begin
	with AylikKar as(
		select
			format(S.SatisTarihi, 'yyyy-MM') as Ay,
			sum(S.SatisTutari - A.Fiyat) as AylikKar
		from Satislar S
		JOIN Arabalar A ON S.ArabaID=A.ArabaID
		GROUP BY
			FORMAT(S.SatisTarihi, 'yyyy-MM')
	),
	OrtalamaKar as(
		select avg(AylikKar) as OrtalamaKar from AylikKar
	)
	select
		AylikKar.Ay,
		S.SatisID,
		S.SatisTarihi,
		S.SatisTutari,
		A.Marka+ ' ' + A.Model as Arac
	from Satislar S
	JOIN Arabalar A ON S.ArabaID=A.ArabaID
	JOIN AylikKar on format(S.SatisTarihi, 'yyyy-MM') = AylikKar.Ay
	CROSS JOIN OrtalamaKar
	where AylikKar.AylikKar < OrtalamaKar.OrtalamaKar
	order by AylikKar asc;
end;


exec sp_OrtalamaAltindakiSatislar;


--3-belli tarihteki satýþlarý listeleme
create procedure sp_SatislariListele
	@Tarih date
as
begin
	select
		S.SatisID,
		M.Ad+ ' ' + M.Soyad as MusteriAdi,
		A.Marka+ ' '+ A.Model as Arac,
		S.SatisTutari
		from Satislar S
		JOIN Musteriler M ON S.MusteriID = M.MusteriID
		JOIN Arabalar A ON S.ArabaID = A.ArabaID
		WHERE 
			CAST(S.SatisTarihi as date) = @Tarih;
end;

exec sp_SatislariListele @Tarih = '2022-12-12'

--4- Personel zam yapma

create procedure sp_PersonelZam
	@PersonelID INT,
	@YuzdeArtis decimal(5,2)
as
begin
	update Personeller
	set Maas = Maas + (Maas * @YuzdeArtis/100)
	where PersonelID = @PersonelID;
end;


exec sp_PersonelZam @PersonelID = 1, @YuzdeArtis=10

--5- SATIÞ EKLEME PROSEDÜRÜ

CREATE PROCEDURE sp_SatisEkle
	@MusteriID INT,
	@ArabaID INT,
	@SatisTutari decimal (10,2),
	@OdemeYontemi varchar(30),
	@PersonelID INT
AS
BEGIN
	INSERT INTO Satislar(MusteriID, ArabaID, SatisTarihi, SatisTutari , OdemeYontemi, PersonelID)
	values (@MusteriID, @ArabaID, getdate(), @SatisTutari, @OdemeYontemi, @PersonelID);
end;


exec sp_SatisEkle @MusteriID = 2, @ArabaID= 3, @SatisTutari=1250000, @OdemeYontemi='nAKÝT', @PersonelID=3

--------------tablodaki verileri silme
truncate table Araclar;   --mesela truncate Musteriler;   ýdleri sýfýrlar

delete ArabaStoklari;     --mesela delete Musteriler;     ýdleri sýfýrlamaz kaldýðý yerden devam eder