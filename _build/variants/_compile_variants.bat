@ECHO OFF
SETLOCAL ENABLEDELAYEDEXPANSION

ECHO ==========================================
ECHO   KnockoutCoins Variant Compiler
ECHO ==========================================

FOR /r %%F IN (*.lua) DO (
    SET "fname=%%~nxF"
    IF /I NOT "!fname:~0,1!"=="_" (
        ECHO [+] Compiling %%~nxF
        PUSHD "%%~dpF"
        luac -s "%%~nxF"
        IF EXIST luac.out (
            MOVE /Y "luac.out" "%%~nF.lur" >nul
            ECHO     ✓ Done: %%~nF.lur
        ) ELSE (
            ECHO     ✗ Failed: no output file
        )
        POPD
    )
)

ECHO.
ECHO ✅ All done!
PAUSE
