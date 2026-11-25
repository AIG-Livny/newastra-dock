#!/bin/bash

# Этот скрипт выполняется при создании образа внутри контейнера

set -e

# Хидер подключается первым
source $COMMON_INSIDE_PATH/header-make-image

# Локальный репозиторий, если он есть
if [ -d "$INSIDE_PATH/localrepo" ]; then
  echo "deb [trusted=yes] file:$INSIDE_PATH/localrepo ./" > /etc/apt/sources.list.d/00-local.list
fi

# Зеркала
if ls $INSIDE_PATH/10*.list >/dev/null 2>&1; then
    ln -sf $INSIDE_PATH/10*.list /etc/apt/sources.list.d/
fi

# Установка пакетов из списка packages-list.txt
DEBIAN_FRONTEND=noninteractive apt install -yqq $(cat $INSIDE_PATH/packages-list.txt)

# Python
pip install $(cat $INSIDE_PATH/pip-packages.txt)

# Копируем актуальный pretty printer для правильного отображения русского языка в дебаггере
sudo cp -r $INSIDE_PATH/pretty_printer/libstdcxx/ /usr/share/gcc/python/

# Локали
locale-gen ru_RU.UTF-8

# Oracle client
dpkg -i $INSIDE_PATH/packages/oracle-instantclient19.5*
mkdir -p $ORACLE_INSTANT && mkdir -p $ORACLE_INSTANT/sdk
ln -s $ORACLE_HOME $ORACLE_INSTANT/sdk/include
ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

## Настройка пользователя

# Удалим стандартного пользователя
if id -u ubuntu >/dev/null 2>&1; then
  userdel -r ubuntu
fi

groupadd -g $DOCK_GID $DOCK_USER
useradd -u $DOCK_UID -g $DOCK_GID -m -s /bin/bash -G $DOCK_USER,sudo $DOCK_USER
echo "$DOCK_USER:$DOCK_PASS" | chpasswd
touch /home/$DOCK_USER/.hushlogin

# Completions
ln -s $INSIDE_PATH/*-completion /etc/bash_completion.d/

# Ссылки на библиотеки для oracle
libs_to_ref=(
    "libclntshcore.so.19.1"
    "libclntsh.so.19.1"
    "libocci.so.19.1"
    "libclntshcore.so"
    "libclntsh.so"
    "libipc1.so"
    "libmql1.so"
    "libnfsodm19.so"
    "libnnz19.so"
    "libociei.so"
    "libocijdbc19.so"
    "liboramysql19.so"
    "libsqlplusic.so"
    "libsqlplus.so"
)

for lib in "${libs_to_ref[@]}"; do
  ln -snf $ORACLE_HOME/lib/$lib $ORACLE_INSTANT/$lib
done

# Пусть при входе показывает инфу о контейнере и переходит в папку src
echo 'cd $APP_SRC_PATH/src' >> /home/$DOCK_USER/.bashrc
echo 'print-logon-message' >> /home/$DOCK_USER/.bashrc
echo "export USER=$DOCK_USER" >> /home/$DOCK_USER/.bashrc

mkdir -p $APP_RUN_PATH
chown -R $DOCK_USER $(dirname $APP_RUN_PATH)

# Подключаем общий компонент после создания пользователя
source $COMMON_INSIDE_PATH/make-image

# Права на файлы передаём пользователю
chown -R $DOCK_USER /home/$DOCK_USER