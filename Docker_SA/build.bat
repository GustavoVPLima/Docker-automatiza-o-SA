@echo off
setlocal EnableDelayedExpansion

REM ===== CONFIGURACOES =====
set REPO=https://github.com/GustavoVPLima/FalaiSA.git
set PASTA_PROJETO=FalaiSA
set NETWORK=falai-net
set IMG_PHP=falai-php-apache
set IMG_MYSQL=falai-mysql
set CT_PHP=falai-web
set CT_MYSQL=falai-db
set PORTA_WEB=8080
set PORTA_DB=3307
REM =========================

cd /d "%~dp0"

echo [1/6] Verificando Docker...
docker info >nul 2>&1
if errorlevel 1 (
    echo ERRO: Docker nao esta em execucao. Abra o Docker Desktop e tente novamente.
    pause & exit /b 1
)

echo [2/6] Verificando projeto...
if not exist "%PASTA_PROJETO%\.git" (
    where git >nul 2>&1
    if errorlevel 1 (
        echo ERRO: Git nao instalado. Instale em https://git-scm.com
        pause & exit /b 1
    )
    git clone %REPO% %PASTA_PROJETO%
    if errorlevel 1 ( echo ERRO no git clone. & pause & exit /b 1 )
) else (
    echo Projeto ja existe, clone ignorado.
)

echo [3/6] Preparando scripts SQL do banco...
if exist db_init rmdir /s /q db_init
mkdir db_init
set ACHOU=0
for /r "%PASTA_PROJETO%" %%f in (*.sql) do (
    copy /y "%%f" "db_init\" >nul
    echo   SQL encontrado: %%~nxf
    set ACHOU=1
)
if "!ACHOU!"=="0" echo   AVISO: nenhum .sql encontrado no projeto. O banco sera criado vazio.
if "!ACHOU!"=="0" echo -- vazio> db_init\00_vazio.sql

echo [4/6] Construindo imagens...
docker build -f Dockerfile.mysql -t %IMG_MYSQL% .
if errorlevel 1 ( echo ERRO ao construir imagem MySQL. & pause & exit /b 1 )
docker build -f Dockerfile.php -t %IMG_PHP% .
if errorlevel 1 ( echo ERRO ao construir imagem PHP/Apache. & pause & exit /b 1 )

echo [5/6] Criando network...
docker network inspect %NETWORK% >nul 2>&1 || docker network create %NETWORK%

echo [6/6] Subindo conteineres...
docker rm -f %CT_MYSQL% %CT_PHP% >nul 2>&1
docker run -d --name %CT_MYSQL% --network %NETWORK% -p %PORTA_DB%:3306 %IMG_MYSQL%
echo Aguardando o MySQL inicializar (30s)...
timeout /t 30 /nobreak >nul
docker run -d --name %CT_PHP% --network %NETWORK% -p %PORTA_WEB%:8080 %IMG_PHP%
if errorlevel 1 (
    echo ERRO: nao foi possivel subir o conteiner web. A porta %PORTA_WEB% pode estar em uso. Altere PORTA_WEB no topo do script.
    pause & exit /b 1
)

echo.
echo ===== PRONTO =====
echo Acesse: http://localhost:%PORTA_WEB%
echo Host do banco para o PHP: %CT_MYSQL%  (usuario: root / senha: root / banco: falaisa)
start chrome http://localhost:%PORTA_WEB%
pause
