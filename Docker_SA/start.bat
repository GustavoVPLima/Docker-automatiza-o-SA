@echo off
echo Iniciando conteineres existentes...
docker start falai-db
timeout /t 10 /nobreak >nul
docker start falai-web
start chrome http://localhost:8080
pause
