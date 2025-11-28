@echo off
setlocal enabledelayedexpansion
@echo off
if exist "%~dp0\Content\" (
    echo The 'Content' directory exists, exiting the script.
    pause
    exit
) 

set "searchFile=G01ProjectFlag.md"
set "currentDir=%~dp0"
set "targetFolder="

for /d %%i in ("%currentDir%..\*") do (
    if exist "%%i\!searchFile!" (
        set "targetFolder=%%i\Content"
        goto foundTargetFolder
    )
)

:foundTargetFolder
if defined targetFolder (
    echo Folder '!targetFolder!' contains file '!searchFile!'.
    if exist "!targetFolder!" (
        echo Creating symbolic link... !targetFolder! to .\Content
        mklink /j .\Content %targetFolder%
        if errorlevel 1 (
            echo Failed to create symbolic link.
        ) else (
            echo ===========================
            echo Success!!!
            echo ===========================
        )
    ) else (
        echo Directory '!targetFolder!' does not exist.
    )
    chcp !OriginalCodePage! > nul
) else (
    echo A folder containing '!searchFile!' was not found.
)
pause
endlocal
