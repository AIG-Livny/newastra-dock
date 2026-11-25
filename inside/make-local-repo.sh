ln -s $INSIDE_PATH/10*.list /etc/apt/sources.list.d/
apt-get update
apt-get install -yqq dpkg-dev
apt-get install -dyqq $(cat $INSIDE_PATH/packages-list.txt)
mkdir -p $INSIDE_PATH/localrepo
mv /var/cache/apt/archives/*.deb $INSIDE_PATH/localrepo/
cd $INSIDE_PATH/localrepo && dpkg-scanpackages . /dev/null | gzip -9c > Packages.gz
cp $INSIDE_PATH/Release $INSIDE_PATH/localrepo

