@echo off
echo Removendo conteineres, imagens e network...
docker rm -f falai-web falai-db
docker rmi falai-php-apache falai-mysql
docker network rm falai-net
echo Concluido. (A pasta FalaiSA e db_init foram mantidas.)
pause
