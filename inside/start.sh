#!/bin/bash

#
# Финальный этап запуска контейнера
#
# Окружение экземпляра (в т.ч. строки подключения к базам) уже лежит в /etc/environment:
# файл создаётся на хосте при создании экземпляра и копируется в контейнер
#

DOCK_USER="$1"

source /etc/environment

git config --global safe.directory $APP_SRC_PATH

if is_based_on stable; then
    ln -s $INSIDE_PATH/.psqlrc_stable /home/$DOCK_USER/.psqlrc
else
    ln -s $INSIDE_PATH/.psqlrc /home/$DOCK_USER/
fi

if is_old_boost; then
    dpkg -i $INSIDE_PATH/packages/libssl1.0.0_1.0.2n-1ubuntu5.13_amd64.deb
    dpkg -i $INSIDE_PATH/packages/libssl1.0-dev_1.0.2n-1ubuntu5.13_amd64.deb
else
    DEBIAN_FRONTEND=noninteractive apt install -yqq libssl-dev > /dev/null 2>&1
    #dpkg -i $INSIDE_PATH/packages/libssl-dev_1.1.1f-1ubuntu2.23_amd64.deb
fi

# Запускаем от имени пользователя
sudo -H -u $DOCK_USER bash -c 'source /etc/environment && astra-init'

service ssh start