@echo off

cd "D:\000\验收文档\服务"

dir 

@REM pause; exit

@REM for /f %%f in ('dir /b .') do (
for %%f in (*) do (
echo %%f
E:\local\bin\saveToPdf.js "%%f"
)

pause
