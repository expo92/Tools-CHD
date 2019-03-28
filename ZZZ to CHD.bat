echo off
chcp 65001
cls
echo. ******************************************************************
echo. *                                                                *
echo. *                           ZZZ to CHD                           *
echo. *                                                                *
echo. *               https://t.me/RaspberryPiEmuladores               *
echo. ******************************************************************
Timeout /t 2 >nul

set ex=cue
set initpath=%CD%
set inppath=%CD%\Input
set outpath=%CD%\Out
set zip=N
set vchd=145

:config
cls
echo. ************************************************************************************************
echo.
echo. *** Default confing / Configuración por defecto ***
echo.
echo. ** Input extension: / Extensión de entrada: (Press [1] to change) ** 
echo. ** toc, cue, nrg, gdi ** 
echo. %ex%
echo.
echo. ** Input folder: / Ruta de entrada: (Press [2] to change) ** 
echo. %inppath%
echo.
echo. ** Output folder: / Ruta de salida: (Press [3] to change) ** 
echo. %outpath%
echo.
echo. ** Are compressed files (.zip/.7z/.rar)? / ¿Son archivos comprimidos? (Press [4] to change) ** 
echo. %zip%
echo.
echo. ** chdman version: / Versión chdman: (Press [5] to change) ** 
echo. %vchd%
echo.
echo. ************************************************************************************************
echo. [Y] Continue,  [N] Exit,  [1-5] Change confing. And press ENTER
echo. [Y] Continuar, [N] Salir, [1-5] Cambiar la configuración. Y pulsa INTRO
echo.

set /P conf=
if /I "%conf%"=="Y" goto :continue
if /I "%conf%"=="N" goto :exit
if "%conf%"=="1" goto :conf1
if "%conf%"=="2" goto :conf2
if "%conf%"=="3" goto :conf3
if "%conf%"=="4" goto :conf4
if "%conf%"=="5" goto :conf5
echo. *** Only [1-5] or [Y/N] // Sólo [1-5] o [Y/N] ***
Timeout /t 4 >nul
goto :config

:conf1
cls
echo.
echo. *** Write input extension (for example: gdi) and press ENTER ***
echo. *** Escribe la extensión de entrada (ej: gdi) y pulsa INTRO ***
echo.
set /P ex=
goto :config

:conf2
cls
echo.
echo. *** Write input folder path (for example: C:\roms) and press ENTER ***
echo. *** Escribe la ruta de entrada (ej: C:\roms) y pulsa INTRO ***
echo.
set /P inppath=
goto :config

:conf3
cls
echo.
echo. *** Write output folder path (for example: C:\roms\CHD output) and press ENTER ***
echo. *** Escribe la ruta de salida (ej: C:\roms\CHD output) y pulsa INTRO ***
echo.
set /P outpath=
goto :config

:conf4
echo.
echo. *** Are the input files .zip/.7z/.rar? [Y/N] ***
echo. *** ¿Los archivos de entrada son .zip/.7z/.rar? [Y/N] ***
echo.
set /P zip=
if /I "%zip%"=="Y" goto :config
if /I "%zip%"=="N" goto :config
echo. *** Only [Y/N] // Sólo [Y/N] ***
Timeout /t 4 >nul
goto :conf4

:conf5
cls
echo.
echo. *** Write chdman version (for example: 196) and press ENTER ***
echo. *** Escribe la versión de chdman (ej: 196) y pulsa INTRO ***
echo.
set /P vchd=
echo %vchd%|findstr /xr "[1-9][0-9]* 0" >nul && (
	goto :config
	) || (
	echo %vchd% is NOT a valid number / %vchd% NO es un número válido
	Timeout /t 4 >nul
	goto :conf5
)
goto :config


:continue
cls
echo.
echo. *** Go Go Go! // Vámonos Átomos! *** 
echo.
Timeout /t 2 >nul
cls
set hour=%time:~0,2%
if "%hour:~0,1%" == " " set hour=0%hour:~1,1%
set min=%time:~3,2%
if "%min:~0,1%" == " " set min=0%min:~1,1%
set secs=%time:~6,2%
if "%secs:~0,1%" == " " set secs=0%secs:~1,1%
set log="%initpath%/log.%date:~-4%.%date:~3,2%.%date:~0,2%.-%hour%.%min%.%secs%.txt"

echo.[%DATE%-%TIME%] Initialization Log>>%log%
echo.Default confing>>%log%
echo.-Input extension: %ex%>>%log%
echo.-Input folder: %inppath%>>%log%
echo.-Output folder: %outpath%>>%log%
echo.-Chdman version: %vchd%>>%log%

if not exist "%outpath%" md "%outpath%" 

if /I "%zip%"=="Y" (
	set tmpdir=%initpath%\tmp
	set exrom=*.zip *.7Z *.rar
	) else (
	set exrom=*.%ex%
	)

cd %inppath%
for /R %%E in (%exrom%) do (
	echo.*** Processing %%~nE ***
	echo.--Processing %%~nE>>%log%
	echo.[%DATE%-%TIME%] Processing %%~nE>>%log%
	if /I "%zip%"=="Y" (
		echo.Please Wait. Extracting %%E to tmp
		echo.[%DATE%-%TIME%] Extracting %%E to tmp>>%log%
		if not exist "%tmpdir%" md %tmpdir% 
		echo.[%DATE%-%TIME%] Init 7Z>>%log%		
		"%initpath%\7z.exe" x "%%E" -o"%tmpdir%" -y>>%log%
		echo.[%DATE%-%TIME%] End 7Z>>%log%		
	
		cd %tmpdir%
		for /R %%Z in (*.%ex%) do (
			echo.Converting %%~nZ.%ex% to %%~nZ.chd
			echo.Create CHD -i "%tmpdir%\%%~nZ.%ex%" -o "%outpath%\%%~nZ.chd" 
			echo.[%DATE%-%TIME%] Create CHD -i "%tmpdir%\%%~nZ.%ex%" -o "%outpath%\%%~nZ.chd">>%log%
			echo.[%DATE%-%TIME%] Init CHDMAN>>%log%
			if %vchd% GEQ 146 ( "%initpath%\chdman" createcd -i "%%Z" -o "%outpath%\%%~nZ.chd" -f>>%log% 
				) else ( "%initpath%\chdman" -createcd "%%Z" "%outpath%\%%~nZ.chd">>%log% )
			echo.[%DATE%-%TIME%] End CHDMAN>>%log%
		)
		echo.Cleaning temp files in %tmpdir%
		echo.[%DATE%-%TIME%] Cleaning temp files in %tmpdir%>>%log%
		FOR /R /r %%Z IN (*.*) DO ( 
			echo.Delete %%Z 
			echo.[%DATE%-%TIME%] Delete: %%Z>>%log%
			del "%%Z" /q>>%log%
		) 		
		echo.Delete all Subfolders of %tmpdir%
		echo.[%DATE%-%TIME%] Delete all Subfolders of %tmpdir%>>%log%
		IF exist "%tmpdir%" rd/s/q "%tmpdir%">>%log%		
		echo.End of cleaning temp files
		echo.[%DATE%-%TIME%] End of cleaning temp files>>%log%
	) else (
		echo.Converting %%~nE.%ex% to %%~nE.chd
		echo.Create CHD -i "%inppath%\%%~nE.%ex%" -o "%outpath%\%%~nE.chd" 
		echo.[%DATE%-%TIME%] Create CHD -i "%inppath%\%%~nE.%ex%" -o "%outpath%\%%~nE.chd">>%log%		
		echo.[%DATE%-%TIME%] Init CHDMAN>>%log%
		if %vchd% GEQ 146 ( "%initpath%\chdman" createcd -i "%%E" -o "%outpath%\%%~nE.chd" -f>>%log%
			) else ( "%initpath%\chdman" -createcd "%%E" "%outpath%\%%~nE".chd>>%log% )
		echo.[%DATE%-%TIME%] End CHDMAN>>%log%
	)

	echo.
	echo.>>%log%
)

if /I "%zip%"=="Y" (
	echo.Delete folder %tmpdir%
	echo.[%DATE%-%TIME%]Delete folder %tmpdir%>>%log%
	IF exist "%tmpdir%" rmdir /s /q  "%tmpdir%">>%log%
)

echo.[%DATE%-%TIME%] End Log>>%log%
:exit
echo.End / Fin del proceso
echo. 
pause
