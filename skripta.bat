@echo off
@title LV13 Ponavljanje - Skripta
mode cin:cols=80 lines=17
color 17

set korisnik=%username%

if "%PROCESSOR_ARCHITECTURE%" EQU "amd64" (
>nul 2>&1 "%SYSTEMROOT%\SysWOW64\cacls.exe" "%SYSTEMROOT%\SysWOW64\config\system"
) else (
>nul 2>&1 "%SYSTEMROOT%\system32\cacls.exe" "%SYSTEMROOT%\system32\config\system"
)

if '%errorlevel%' NEQ '0' (
    echo -- Potrebne su mi administratorske privilegije --
    goto UACPrompt
) else ( goto gotAdmin )


:UACPrompt
    echo Set UAC = CreateObject^("Shell.Application"^) > "%temp%\getadmin.vbs"
    set params= %*
    echo UAC.ShellExecute "cmd.exe", "/c ""%~s0"" %params:"=""%", "", "runas", 1 >> "%temp%\getadmin.vbs"

    "%temp%\getadmin.vbs"
    del "%temp%\getadmin.vbs"
    exit /B

:gotAdmin
    pushd "%CD%"
    CD /D "%~dp0"
    echo -- Imam sve potrebne privilegije --

echo.
echo ***********************************************
echo              SKRIPTA ZA LJENCINE
echo          Rjesenja za LV13 Ponavljanje
echo ***********************************************
echo.
echo Made by BrownBird Team
echo.
echo Upravljanje skriptom:
echo.
echo [n] Upisite broj zadatka za izvrsavanje zadatka
echo.
echo NOTE: zadaci su povezani ukoliko zatrazite izvrsavanje
echo       zadatka koji ovisi o prethodnom moze doci do
echo       nepredvidljivog ponasanja skripte, preporucam rjesavati
echo       zadatke po redu
echo.
echo [c] Upisite za prestanak izvrsavanja
echo [d] Upisite za brisanje radnog direktorija
echo [s] Upisite za brisanje djeljenog direktorija (preporucam)
echo.
echo [ls] Ispis liste zadataka
echo [cd] Upisite za ispis trenutnog direktorija
pause

setLocal enableDelayedExpansion

echo.
echo Krenimo sa zadacima, za pocetak mi trebaju neki podaci
set /p ime="Upisi svoje ime: "
set /p prez="Upisi svoje prezime: "

:folderprompt
echo.
echo Vase korisnicko ime je %korisnik%
set /p mydf="Je li C:\Users\%korisnik%\Desktop vas desktop folder [y/n] "

echo.
if "%mydf%" EQU "n" (
	set /p mydf="Upisite punu putanju do svog desktop foldera: "
) else if "%mydf%" EQU "y" (
	set mydf="C:\Users\%korisnik%\Desktop"
) else (
	goto folderprompt
)

C:
cd %mydf%
for /f "tokens=*" %%p in ('cd') do (
	set mysharepath=%%p\%ime%%prez%
)

set /a cnt=4

goto myloop

:myloop
set "prmpt="
if %cnt% EQU 19 (
	set /p prmpt="%ime%@skripta [i] > "
) else (
	set /p prmpt="%ime%@skripta [%cnt%] > "
)
if "%prmpt%" EQU "" (
	set prmpt=-1
)
if "%prmpt%" NEQ "-1" (
	if "%prmpt%" EQU "c" (
		goto end
	) else if "%prmpt%" EQU "s" (
		call :rmshare
		set /a cnt=19
		goto myloop
	) else if "%prmpt%" EQU "d" (
		call :rmfolder
		set /a cnt=19
		goto myloop
	) else if "%prmpt%" EQU "cd" (
		cd
		goto myloop
	) else if "%prmpt%" EQU "ls" (
		call :list
		goto myloop
	) else (
		set "var="&for /f "delims=0123456789" %%i in ("%prmpt%") do set var=%prmpt%
		if defined var (
			goto myloop
		) else (
			if %prmpt% LSS 19 (
				set /a cnt=%prmpt%
			) else (
				goto myloop
			)
		)
	)
)
if %cnt% LSS 19 (
	echo Zapocinjem rjesavanje %cnt%. zadatka
	call :zad%cnt%
) else if %cnt% EQU 19 (
	echo.
	echo Zavrsili ste posljednji zadatak ?
	echo savjetujem da obrisete share upisivanjem slova [s]
	echo radni direktorij mozete obrisati upisivanjem slova [d]
	echo a za kraj izvrsavanja upisite [c]
	echo.
	goto myloop
)
set /a cnt+=1
goto myloop

:zad4
cd %mydf%
echo Stvaram folder i datoteke na radnoj povrsini
rmdir /s /q %ime%%prez% > nul 2<&1
mkdir %ime%%prez%
cd %ime%%prez%
type nul > Skriveno.txt
type nul > PopisAtributa.txt
type nul > SadrzajDirektorija.txt
echo Postavljam skriveni atribut na datoteku Skriveno.txt
attrib +H Skriveno.txt
echo Gotov
echo.
exit /b 0


:zad5
echo Spremam popis atributa i sadrzaj direktorija u datoteke
echo %prez% > PopisAtributa.txt
attrib Skriveno.txt >> PopisAtributa.txt
dir /b > SadrzajDirektorija.txt
echo Gotov
echo.
exit /b 0


:zad6
echo Spremam sortirani sadrzaj direktorija u SortiranSadrzaj.txt
dir /b | sort /+10 > SortiranSadrzaj.txt
echo Gotov
echo.
exit /b 0


:zad7
echo Filtriram prvi i posljednji stupac sadrzaja direktorija
echo u datoteku FiltriraniSadrzaj.txt
set /a counter=0

for /f "skip=4 tokens=*" %%l in ('dir') do (
	set /a counter+=1
)

set /a counter-=2
type nul > FiltriraniSadrzaj.txt

for /f "skip=4 tokens=1,5" %%g in ('dir') do (
	if !counter! NEQ 0 (
		echo %%g %%h >> FiltriraniSadrzaj.txt
		set /a counter-=1
	)
)
echo Gotov
echo.
exit /b 0


:zad8
echo Kreiram korisnika %prez%%ime%
net user %prez%%ime% provjera /add > nul 2>&1
echo Kreiram grupu %prez%
net localgroup %prez% /add > nul 2>&1
echo Dodajem korisnika u grupu
net localgroup %prez% %prez%%ime% /add > nul 2>&1
echo Gotov
echo.
exit /b 0


:zad9
echo Spremam ime i SID korisnika u datoteku Grupe_i_Korisnici.txt
type nul > Grupe_i_Korisnici.txt
echo --- Detalji korisnika --- >> Grupe_i_Korisnici.txt
wmic useraccount where name="%prez%%ime%" get name,sid > temp.txt
type temp.txt >> Grupe_i_Korisnici.txt
del temp.txt
echo. >> Grupe_i_Korisnici.txt
echo Spremam clanove grupe %prez% u datoteku Grupe_i_Korisnici.txt
echo --- Clanovi u grupi --- >> Grupe_i_Korisnici.txt

setLocal enableDelayedExpansion

set /a counter=0

for /f "skip=6 tokens=*" %%l in ('net localgroup %prez%') do (
	set /a counter+=1
)

set /a counter-=1

for /f "skip=6 tokens=*" %%g in ('net localgroup %prez%') do (
	if !counter! NEQ 0 (
		echo %%g >> Grupe_i_Korisnici.txt
		set /a counter-=1
	)
)

echo Brisem grupu i korisnika
net user %prez%%ime% /delete > nul 2>&1
net localgroup %prez% /delete > nul 2>&1

echo Gotov
echo.
exit /b 0


:zad10
echo Kreiram korisnike Ispit1-5
for /l %%p in (1,1,5) do (
	net user Ispit%%p /add > nul 2>&1
)
echo Gotov
echo.
exit /b 0


:zad11
echo Onemogucujem korisnike Ispit1-5
for /l %%p in (1,1,5) do (
	wmic useraccount where name="Ispit%%p" set disabled=true > nul 2>&1
)
echo Gotov
echo.
exit /b 0


:zad12
echo Spremam status korisnika u datoteku Status.txt
wmic useraccount get name,disabled | findstr "Disabled Ispit" > Status.txt
echo Brisem korisnike
for /l %%p in (1,1,5) do (
	net user Ispit%%p /delete > nul 2>&1
)
echo Gotov
echo.
exit /b 0


:zad13
echo Kreiram Network Share
net share %ime%%prez%=%mysharepath% /grant:Everyone,READ > nul 2>&1
if %errorlevel% NEQ 0 (
	echo GRESKA pokusajte izvrsiti naredbu [s] zatim ponovite zadatak
)
for /f "tokens=*" %%p in ('hostname') do (
	set myhostname=%%p
)
echo Postavljam slovo Z kao share
net use z: \\%myhostname%\%ime%%prez% > nul 2>&1
if %errorlevel% NEQ 0 (
	echo GRESKA pokusajte izvrsiti naredbu [s] zatim ponovite zadatak
)
echo Gotov
echo.
exit /b 0

:zad14
echo Ispisujem sadrzaj djeljenog direktorija
Z:
dir > %mysharepath%\NetShare.txt
C:
echo Gotov
echo.
exit /b 0

:zad15
echo Provjeravam postoji li PopisAtributa.txt
if exist PopisAtributa.txt (
	echo Datoteka PopisAtributa.txt postoji !
) else (
	type nul > PopisAtributa.txt
)
echo Gotov
echo.
exit /b 0

:zad16
if exist %mydf%\Primjer\ (
	echo Direktorij postoji
) else (
	echo Stvaram direktorij
	mkdir %mydf%\Primjer > nul 2>&1
)

cd %mydf%\Primjer
echo Radni direktorij:
cd

set /p baza="Upisi bazu imena datoteke: "
set /p string="Upisi broj novih datoteka: "
set /a num=%string%

echo.
for /l %%i in (1,1,%num%) do (
	echo Stvaram novu datoteku %baza%%%i.txt
	type nul > %baza%%%i.txt
)

set /a prvapolovica=%num%/2
set /a drugapolovica=%num%-%prvapolovica%

echo.
for /l %%i in (1,1,%prvapolovica%) do (
	echo Postavljam Read only atribut na datoteku %baza%%%i.txt
	attrib +R %baza%%%i.txt
)
echo.
for /l %%i in (%drugapolovica%,1,%num%) do (
	echo Postavljam skriveni atribut na datoteku %baza%%%i.txt
	attrib +H %baza%%%i.txt
)
echo.
echo Gotov
echo.
exit /b 0

:zad17
if exist %mydf%\Radno\ (
	echo Direktorij postoji
) else (
	echo Stvaram direktorij
	mkdir %mydf%\Radno > nul 2>&1
)

cd %mydf%\Radno
echo Radni Direktorij:
cd
echo Stvaram direktorij BACKUP
if exist %mydf%\Radno\BACKUP\ (
	echo Direktorij vec postoji
) else (
	mkdir BACKUP
)
echo Stvaram Datoteku Orginal.txt
type nul > Orginal.txt

echo Spremam pricuvnu kopiju datoteke Orginal.txt
copy Orginal.txt BACKUP\Orginal.bkp > nul
dir BACKUP\Orginal.bkp > nul
if %errorlevel%  EQU 0 (echo Datoteka je uspjesno kopirana) else (echo Doslo je do greske)
echo.
echo Micem ARCHIVE atribut sa datoteke Orginal.txt
attrib -a Orginal.txt
echo Upisujem sadrzaj u datoteku, koristeci random varijablu
echo %random% >> Orginal.txt
echo.

for /f "tokens=1" %%i in ('echo A') do (
	if "%%i" EQU "A" (
		echo Datoteka je spremna za ponovno arhiviranje
	) else (
		echo Nije doslo do izmjena
	)
)

echo Spremam pricuvnu kopiju datoteke pod nazivom OrginalDDMMYYYY-HHMM.bkp
copy Orginal.txt BACKUP\Orginal%date:~4,2%%date:~7,2%%date:~10,4%-%time:~0,2%%time:~3,2%.bkp > nul
dir BACKUP\Orginal%date:~4,2%%date:~7,2%%date:~10,4%-%time:~0,2%%time:~3,2%.bkp > nul
if %errorlevel% EQU 0 (
	echo Datoteka uspjesno kreirana
) else (
	echo Doslo je do greske
)
echo Gotov
echo.
exit /b 0

:zad18
cd %mydf%
echo Generiram 10 nasumicnih brojeva
echo Spremam ih u datoteku Random.txt na desktopu
type nul > Random.txt
for /l %%i in (1,1,10) do (
	set /a rand=%random% %%10
	set /a rand=!Random! %%10
	echo Local !rand! >> Random.txt
	echo Global %rand% >> Random.txt
)
echo Gotov
echo.
exit /b 0

:rmshare
echo Brisem Network Share
net use z: /delete /y > nul 2>&1
net share /delete %ime%%prez% > nul 2>&1
exit /b 0

:rmfolder
cd %mydf%
if exist %mysharepath%\ (
	echo Brisem direktorij %ime%%prez%
	rmdir /s /q %mysharepath% > nul 2>&1
) else (
	echo Direktorij %ime%%prez% ne postoji
)
if exist %mydf%\Radno\ (
	echo Brisem direktorij Radno
	rmdir /s /q %mydf%\Radno\ > nul 2>&1
) else (
	echo Direktorij Radno ne postoji
)
if exist %mydf%\Primjer\ (
	echo Brisem direktorij Primjer
	rmdir /s /q %mydf%\Primjer\ > nul 2>&1
) else (
	echo Direktorij Primjer ne postoji
)
if exist %mydf%\Random.txt (
	echo Brisem datoteku Random.txt
	del %mydf%\Random.txt > nul 2>&1
) else (
	echo Datoteka Random.txt ne postoji
)
echo Gotov
echo.
exit /b 0

:list
echo.
echo 4. Stvoriti na radnoj povrsini direktorij PrezimeIme (upisati svoje ime i
echo prezime). Unutar direktorija stvoriti tri datoteke : Skriveno.txt i
echo PopisAtributa.txt i SadrzajDirektorija.txt. Postaviti skriveni atribut
echo na datoteku Skriveno.txt. 
echo.
echo 5. Preusmjeriti tekst sa prezimenom ucenika u datoteku PopisAtributa.txt.
echo Nadodati u datoteku PopisAtributa.txt popis atributa datoteke Skriveno.txt.
echo Ispisati kompletan sadrzaj direktorija (neovisno o atributima) PrezimeIme u
echo datoteku SadrzajDirektorija.txt.
echo.
echo 6. Ispisati kompletan sadrzaj direktorija (neovisno o atributima) PrezimeIme,
echo sortirati prema 10. znaku te spremiti sadrzaj u datoteku SortiranSadrzaj.txt.
echo.
echo 7. Ispisati kompletan sadrzaj direktorija (neovisno o atributima) PrezimeIme,
echo no u datoteku FiltriraniSadrzaj.txt spremiti samo stupce sa datumom stvaranja
echo i imenima datoteka/direktorija.
pause
echo.
echo 8. Stvoriti korisnicki racun PrezimeIme (upisati svoje ime i prezime) sa
echo lozinkom provjera. Stvoriti lokalnu korisnicku grupu Prezime. Dodati stvorenog
echo korisnika u grupu.
echo.
echo 9. U datoteku Grupe_i_Korisnici.txt unutar direktorija PrezimeIme
echo (upisati svoje ime i prezime) na radnoj povrsini ispisati slijedece:
echo - Tekst "Detalji korisnika"
echo - Korisnicko ime i SID korisnika PrezimeIme Tekst "Clanovi u grupi"
echo - Popis clanova lokalne korisnicke grupe Prezime
echo Obrisati stvoreni korisnicki racun i grupu
echo.
echo 10. Upotrebom petlje stvoriti 5 korisnickih racuna : Ispit1, Ispit2, Ispit3,
echo Ispit4 i Ispit5.
pause
echo.
echo 11. Upotrebom petlje onemoguciti (eng. Disable) korisnicke racune : Ispit1,
echo Ispit2, Ispit3, Ispit4 i Ispit5.
echo.
echo 12. U datoteku Status.txt unutar direktorija PrezimeIme (upisati svoje ime
echo i prezime) na radnoj povrsini ispisati Korisnicko ime i DISABLED status za
echo sve korisnike koji imaju Ispit u svojem korisnickom imenu. Obrisati sve
echo korisnike koji imaju Ispit u svojem korisnickom imenu.
echo.
echo 13. Omoguciti mrezno dijeljenje direktorija PrezimeIme te grupi Everyone
echo dati prava za citanje.  Povezati se na dijeljeni direktorij kao trenutno
echo prijavljeni korisnik, postaviti ga pod slovom Z:
echo.
echo 14. Ispisati sadrzaj korijenskog direktorija Z: particije te preusmjeriti
echo rezultat u datoteku NetShare.txt unutar direktorija PrezimeIme na radnoj
echo povrsini
pause
echo.
echo 15. Upotrebom if naredbe provjeriti postojanje datoteke PopisAtributa.txt
echo unutar direktorija PrezimeIme. U slucaju da datoteka postoji napisati poruku
echo "Datoteka PopisAtributa.txt postoji", u suprotnom stvoriti datoteku. 
echo.
echo 16. Provjeriti postoji li na radnoj povrsini direktorij Primjer, te ako ne
echo postoji, stvoriti ga. Unutar direktorija stvoriti datoteke proizvoljnog imena,
echo broj stvorenih datoteka i baza imena ovise o unosu korisnika za vrijeme
echo izvrsavanja skripte (preporuka je ne premasivati 10 datoteka). Na prvu polovicu
echo stvorenih datoteka postaviti atribut samo za citanje, a na drugu skriveni
echo atribut. Za svaki postupak (stvaranje direktorija, datoteka, mijenjanje
echo atributa) je potrebno izvijestiti korisnika (npr. "echo Stvaram direktorij").
pause
echo.
echo 17. Provjeriti postoji li na radnoj povrsini direktorij Radno, te ako ne
echo postoji, stvoriti ga. Unutar tog direktorija stvoriti direktorij BACKUP.
echo Stvoriti praznu datoteku imena Original.txt (koristiti NUL uredaj prilikom
echo stvaranja. NUL uredaj je posebna vrsta datoteke koja predstavlja "crnu rupu".
echo Sve sto se salje u taj uredaj ce nestati, a sve sto se zeli iz njega izvuci
echo ce biti prazno.). Spremiti originalnu verziju datoteke u direktorij BACKUP
echo u slijedecem obliku : ImeDatotekeDDMMYYYY-HHMM.bkp. Maknuti ARCHIVE atribut
echo sa datoteke (oznacava kako je potrebno spremiti pricuvnu kopiju datoteke).
echo Dodati neki sadrzaj u datoteku. Provjeriti ARCHIVE atribut, te ako je
echo postavljen, ponovno spremiti pricuvnu kopiju datoteke.
echo.
echo 18. Generirati slucajni broj upotrebom specijalne varijable random. Koristiti 
echo EnableDelayedExpansion funkciju (omogucava koristene lokalne promjenjive
echo varijable unutar petlji). Generirati 10 slucajnih brojeva te ih upisati u
echo datoteku Random.txt. Za svaki korak u petlji prikazati vrijednost globalne
echo varijable (omedena znakovima %%) i lokalne varijable (omedena znakovima !!).
echo.
exit /b 0

:end
endlocal
