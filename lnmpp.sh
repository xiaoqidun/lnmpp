#!/bin/bash
logo() {
    cat <<logo
#####################################################################################################
.,kk,.               ,xx      .,d'           .,O0       .0x;.          ;x0c;ckk'           'l0x;:dOl 
  kk                  ;d0l.     c              oxO     .lN;             ,N.   ,N;            Ko   .0O
  kk                  ,. ;Od.   c              l d0.  .c N;             ,N.   :K'            Ko   .0o
  kk                  ,.   'xk, :              l  lK..:  N;             ,N...,.              Ko .''  
  kk     .:           ,.     .lOk.             l   :Kc   N;             ,N.                  Ko      
.,kx''',c0,          ,dc'.      O.           'cd,.  :  'cOd;.          .lOo,               .,Ox;.    
#####################################################################################################
logo
}
path() {
    export PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
}
init() {
    initdate
    check_os
    helloworld
    check_root
    pkg_install
    XPWD=$(pwd)
    ! test -n "$PREFIX" && PREFIX=/opt
    BIN_PREFIX=$PREFIX
    PHP_PREFIX=$PREFIX/atphp
    NGINX_PREFIX=$PREFIX/nginx
    MYSQL_PREFIX=$PREFIX/mysql
    PGSQL_PREFIX=$PREFIX/pgsql
    __XQD_PREFIX=$PREFIX/_xqd_
    LIBMCRYPT_PREFIX=$__XQD_PREFIX/root/libmcrypt
    ! test -n "$DISABLE_MYSQL" && DISABLE_MYSQL=1
    ! test -n "$DISABLE_POSTGRESQL" && DISABLE_POSTGRESQL=1
    NGINX_USER=nginx
    NGINX_GROUP=nginx
    MYSQL_USER=mysql
    MYSQL_GROUP=mysql
    PGSQL_USER=postgres
    PGSQL_GROUP=postgres
    PHPFPM_USER=linux
    PHPFPM_GROUP=linux
    ! test -n "$PHP_VER" && PHP_VER=5.6.40
    ! test -n "$NGINX_VER" && NGINX_VER=1.17.1
    ! test -n "$MYSQL_VER" && MYSQL_VER=5.6.44
    ! test -n "$PGSQL_VER" && PGSQL_VER=11.4
    LIBMCRYPT_VER=2.5.8
    ETC=$XPWD/xiaoqidun/etc
    XQD=$XPWD/xiaoqidun/xqd
    SRC=$XPWD/xiaoqidun/src
    WWW=$XPWD/xiaoqidun/www
    PHP_TAR_SRC=$SRC/php-$PHP_VER.tar.bz2
    NGINX_TAR_SRC=$SRC/nginx-$NGINX_VER.tar.gz
    MYSQL_TAR_SRC=$SRC/mysql-$MYSQL_VER.tar.gz
    PGSQL_TAR_SRC=$SRC/postgresql-$PGSQL_VER.tar.bz2
    LIBMCRYPT_TAR_SRC=$SRC/libmcrypt-$LIBMCRYPT_VER.tar.bz2
    PHP_TAR_SRC_URL=http://php.net/distributions/php-$PHP_VER.tar.bz2
    NGINX_TAR_SRC_URL=http://nginx.org/download/nginx-$NGINX_VER.tar.gz
    MYSQL_TAR_SRC_URL=http://dev.mysql.com/get/Downloads/MySQL-5.6/mysql-$MYSQL_VER.tar.gz
    PGSQL_TAR_SRC_URL=https://ftp.postgresql.org/pub/source/v$PGSQL_VER/postgresql-$PGSQL_VER.tar.bz2
    PHP_SRC_DIR=$SRC/php-$PHP_VER
    NGINX_SRC_DIR=$SRC/nginx-$NGINX_VER
    MYSQL_SRC_DIR=$SRC/mysql-$MYSQL_VER
    PGSQL_SRC_DIR=$SRC/postgresql-$PGSQL_VER
    LIBMCRYPT_SRC_DIR=$SRC/libmcrypt-$LIBMCRYPT_VER
    ! test -n "$NGINX_DEFAULT_WEB_ROOT" && NGINX_DEFAULT_WEB_ROOT=/vhost/default
    ! test -n "$MYSQL_DEFAULT_PASSWORD" && MYSQL_DEFAULT_PASSWORD=root
    ! test -n "$POSTGRESQL_DEFAULT_PASSWORD" && POSTGRESQL_DEFAULT_PASSWORD=postgres
    MAKE_J="-j$(grep -c ^processor /proc/cpuinfo | grep -E '^[1-9]+[0-9]*$' || echo 1)"
    if test "$DISABLE_MYSQL" = "0" ; then
        PHP_MYSQL=""
    else
        if test "$(echo $PHP_VER | cut -b1)" = "7" ; then
            PHP_MYSQL="--with-pdo-mysql=$MYSQL_PREFIX"
        else
            PHP_MYSQL="--with-mysql=$MYSQL_PREFIX --with-pdo-mysql=$MYSQL_PREFIX"
        fi
    fi
    if test "$DISABLE_POSTGRESQL" = "0" ; then
        PHP_PGSQL=""
    else
        PHP_PGSQL="--with-pgsql=$PGSQL_PREFIX --with-pdo-pgsql=$PGSQL_PREFIX"
    fi
    if test "$OS" = "centos" ; then
        PHP_CONFIGURE="./configure --prefix=$PHP_PREFIX --enable-fpm --enable-ftp --enable-zip\
        --enable-soap --enable-wddx --enable-shmop --enable-pcntl --enable-bcmath --enable-sockets\
        --enable-sysvmsg --enable-sysvsem --enable-sysvshm --enable-calendar --enable-mbstring --enable-gd-native-ttf\
        --enable-exif --with-xsl --with-bz2 --with-gmp --with-curl --with-zlib --with-mysqli --with-openssl --with-gettext\
        --with-gd --with-xpm-dir --with-png-dir --with-jpeg-dir --with-freetype-dir --with-mcrypt=$LIBMCRYPT_PREFIX\
        $PHP_PGSQL $PHP_MYSQL"
    else
        PHP_CONFIGURE="./configure --prefix=$PHP_PREFIX --enable-fpm --enable-ftp --enable-zip\
        --enable-soap --enable-wddx --enable-shmop --enable-pcntl --enable-bcmath --enable-sockets\
        --enable-sysvmsg --enable-sysvsem --enable-sysvshm --enable-calendar --enable-mbstring --enable-gd-native-ttf\
        --enable-exif --with-xsl --with-bz2 --with-gmp --with-curl --with-zlib --with-mcrypt --with-mysqli\
        --with-openssl --with-gettext --with-gd --with-xpm-dir --with-png-dir --with-jpeg-dir --with-freetype-dir\
        $PHP_PGSQL $PHP_MYSQL"
    fi
    NGINX_CONFIGURE="./configure --prefix=$NGINX_PREFIX --with-stream --with-stream_ssl_module\
    --with-http_v2_module --with-http_ssl_module --with-http_realip_module --with-http_addition_module\
    --with-http_sub_module --with-http_dav_module --with-http_flv_module --with-http_mp4_module\
    --with-http_gunzip_module --with-http_gzip_static_module --with-http_auth_request_module --with-http_random_index_module\
    --with-http_secure_link_module --with-http_degradation_module --with-http_stub_status_module"
    MYSQL_CONFIGURE="cmake -DCMAKE_BUILD_TYPE:STRING=Release -DCMAKE_INSTALL_PREFIX:PATH=$MYSQL_PREFIX\
    -DFEATURE_SET:STRING=community -DWITH_EXTRA_CHARSETS:STRING=all"
    PGSQL_CONFIGURE="./configure --prefix=$PGSQL_PREFIX --with-openssl"
    LIBMCRYPT_CONFIGURE="./configure --prefix=$LIBMCRYPT_PREFIX"
    test -n "$1" && test "$1" = "binary" && user_group && bin_extract && global_init binary && exit
    ! test -d xiaoqidun/ && xqd_extract
    write_cfg
    user_group
    xqd_download
    tar_extract
    test "$OS" = "centos" && src_install libmcrypt
    src_install nginx
    config_init nginx
    if test "$DISABLE_MYSQL" = "0" ; then
        disable mysql
    else
        src_install mysql
        config_init mysql
    fi
    if test "$DISABLE_POSTGRESQL" = "0" ; then
        disable postgresql
    else
        src_install pgsql
        config_init pgsql
    fi
    src_install _php_
    config_init _php_
    global_init index
}
disable() {
    case "$1" in
        "mysql")
            grep '#\$xpwd/mysql' $__XQD_PREFIX/init/lnmpp >> /dev/null 2>&1
            test "$?" = "1" && sed -i 's|\$xpwd/mysql|#\$xpwd/mysql|' $__XQD_PREFIX/init/lnmpp
        ;;
        "postgresql")
            grep '#\$xpwd/pgsql' $__XQD_PREFIX/init/lnmpp >> /dev/null 2>&1
            test "$?" = "1" && sed -i 's|\$xpwd/pgsql|#\$xpwd/pgsql|' $__XQD_PREFIX/init/lnmpp
        ;;
    esac
}
bg_exec() {
    rm -f $BGEXEC_EXIT_STATUS_FILE
    $@
    echo $? > $BGEXEC_EXIT_STATUS_FILE
}
bg_wait() {
    BGEXEC_EXIT_STATUS_FILE=/tmp/xiaoqidun.status
    bg_exec $@ >> /dev/null 2>&1 &
    wait_pid $!
    ! test -f $BGEXEC_EXIT_STATUS_FILE && exit 2
}
check_os() {
    if cat /etc/issue | grep -i 'ubuntu' >> /dev/null 2>&1 ; then
        OS=ubuntu
        OS_VER=$(cat /etc/issue | head -n1 | awk '{print$2}')
        echo -e SYSTEM: UBUNTU $(uname -m) ${OS_VER}\\nKERNEL: $(uname -sr)
    elif test -f /etc/debian_version ; then
        OS=debian
        OS_VER=$(cat /etc/debian_version)
        echo -e SYSTEM: DEBIAN $(uname -m) ${OS_VER}\\nKERNEL: $(uname -sr)
    elif test -f /etc/centos-release ; then
        OS=centos
        OS_VER=$(cat /etc/centos-release | grep -o -E '[0-9.]{3,}') 2>> /dev/null
        echo -e SYSTEM: CENTOS $(uname -m) ${OS_VER}\\nKERNEL: $(uname -sr)
    else
        echo The system does not support
        exit
    fi
}
initdate() {
    init_date=`date +%s`
}
bin_file() {
    case "$OS" in
        "debian")
            aaaa=`uname -m`
            test "$aaaa" = "i686" && aaaa=x86
            test "$aaaa" = "i386" && aaaa=x86
            test "$aaaa" = "i486" && aaaa=x86
            test "$aaaa" = "i586" && aaaa=x86
            test "$aaaa" = "x86_64" && aaaa=x64
            test "$(echo $aaaa | cut -b1-3)" = "arm" && aaaa=arm
            echo xqd_debian$(echo $OS_VER | awk -F '.' '{print$1}')_$aaaa.bin
        ;;
        "centos")
            aaaa=`uname -m`
            test "$aaaa" = "i686" && aaaa=x86
            test "$aaaa" = "i386" && aaaa=x86
            test "$aaaa" = "i486" && aaaa=x86
            test "$aaaa" = "i586" && aaaa=x86
            test "$aaaa" = "x86_64" && aaaa=x64
            echo xqd_centos$(echo $OS_VER | awk -F '.' '{print$1}')_$aaaa.bin
        ;;
    esac
}
bin_sha1() {
    case "$OS$(echo $OS_VER | awk -F '.' '{print$1}')" in
        "debian7")
            aaaa=`uname -m`
            test "$aaaa" = "i686" && aaaa=x86
            test "$aaaa" = "i386" && aaaa=x86
            test "$aaaa" = "i486" && aaaa=x86
            test "$aaaa" = "i586" && aaaa=x86
            test "$aaaa" = "x86_64" && aaaa=x64
            test "$(echo $aaaa | cut -b1-3)" = "arm" && aaaa=arm
            if test "$aaaa" = "x64" ; then
                echo daa147f2f63b495af1a97d8c05edf37c786cfa2e
            elif test "$aaaa" = "arm" ; then
                echo bc7cb6b16b4ee971d87e260f4bedbe275d9d8b7d
            else
                echo http://aite.xyz/
            fi
        ;;
        "centos7")
            aaaa=`uname -m`
            test "$aaaa" = "i686" && aaaa=x86
            test "$aaaa" = "i386" && aaaa=x86
            test "$aaaa" = "i486" && aaaa=x86
            test "$aaaa" = "i586" && aaaa=x86
            test "$aaaa" = "x86_64" && aaaa=x64
            if test "$aaaa" = "x64" ; then
                echo fe1e901e604b822edd4c2aac239dd24556853378
            else
                echo http://aite.xyz/
            fi
        ;;
        *)
            echo http://aite.xyz/
        ;;
    esac
}
wait_pid() {
    while true ; do
        ps -p $1 >> /dev/null
        if test "$?" = "1" ; then
            break
        fi
        sleep 1
        echo -ne .
        sleep 1
        echo -ne .
        sleep 1
        echo -ne .
        sleep 1
        echo -ne .
        sleep 1
        echo -ne \\b\\b\\b\\b\ \ \ \ \\b\\b\\b\\b
        sleep 1
    done
}
init_exec() {
    case "$1" in
        "--logo")
            logo
            exit
        ;;
        "--help")
            cat <<HELP
Qq:88966001 Qgroup:38181604 
Author: xiaoqidun@gmail.com
Linux nginx mysql pgsql php
---------------------------
--prefix=
--defaultwww=
--mysqlpassword=
--postgresqlpassword=
---------------------------
--disablemysql
--disablepostgresql
---------------------------
--phpversion=
--nginxversion=
--mysqlversion=
--postgresqlversion=
---------------------------
--help
--checkport
---------------------------
HELP
            exit
        ;;
        "--prefix")
            test "$2" != "" && PREFIX="$2"
        ;;
        "--defaultwww")
            test "$2" != "" && NGINX_DEFAULT_WEB_ROOT="$2/default"
        ;;
        "--mysqlpassword")
            test "$2" != "" && MYSQL_DEFAULT_PASSWORD="$2"
        ;;
        "--postgresqlpassword")
            test "$2" != "" && POSTGRESQL_DEFAULT_PASSWORD="$2"
        ;;
        "--phpversion")
            test "$2" != "" && PHP_VER="$2"
        ;;
        "--nginxversion")
            test "$2" != "" && NGINX_VER="$2"
        ;;
        "--mysqlversion")
            test "$2" != "" && MYSQL_VER="$2"
        ;;
        "--postgresqlversion")
            test "$2" != "" && PGSQL_VER="$2"
        ;;
        "--checkport")
            ss -anpl 2>> /dev/null | grep -E ":80|:3306|:5432|\"php-fpm\"" && exit 2
        ;;
        "--disablemysql")
            DISABLE_MYSQL=0
        ;;
        "--disablepostgresql")
            DISABLE_POSTGRESQL=0
        ;;
    esac
}
write_cfg() {
    mkdir -p $PREFIX
    cp -a $XQD $__XQD_PREFIX >> /dev/null 2>&1
    if test "$?" != "0" ; then
        echo Copy sys data fail
        exit
    fi
    cp -a $ETC/n_tpl.conf $__XQD_PREFIX/conf >> /dev/null 2>&1
    cp -a $ETC/p_tpl.conf $__XQD_PREFIX/conf >> /dev/null 2>&1
    if test "$?" != "0" ; then
        echo Copy sys data fail
        exit
    fi
    sed -i "s|{VER}|$VER|" $__XQD_PREFIX/.cfg
    sed -i "s|{PREFIX}|$PREFIX|" $__XQD_PREFIX/.cfg
    sed -i "s|{PHP_PREFIX}|$PHP_PREFIX|" $__XQD_PREFIX/.cfg
    sed -i "s|{NGINX_PREFIX}|$NGINX_PREFIX|" $__XQD_PREFIX/.cfg
    sed -i "s|{MYSQL_PREFIX}|$MYSQL_PREFIX|" $__XQD_PREFIX/.cfg
    sed -i "s|{PGSQL_PREFIX}|$PGSQL_PREFIX|" $__XQD_PREFIX/.cfg
    sed -i "s|{NGINX_USER}|$NGINX_USER|" $__XQD_PREFIX/.cfg
    sed -i "s|{NGINX_GROUP}|$NGINX_GROUP|" $__XQD_PREFIX/.cfg
    sed -i "s|{MYSQL_USER}|$MYSQL_USER|" $__XQD_PREFIX/.cfg
    sed -i "s|{MYSQL_GROUP}|$MYSQL_GROUP|" $__XQD_PREFIX/.cfg
    sed -i "s|{PGSQL_USER}|$PGSQL_USER|" $__XQD_PREFIX/.cfg
    sed -i "s|{PGSQL_GROUP}|$PGSQL_GROUP|" $__XQD_PREFIX/.cfg
    sed -i "s|{PHPFPM_USER}|$PHPFPM_USER|" $__XQD_PREFIX/.cfg
    sed -i "s|{PHPFPM_GROUP}|$PHPFPM_GROUP|" $__XQD_PREFIX/.cfg
    sed -i "s|{NGINX_DEFAULT_WEB_ROOT}|$NGINX_DEFAULT_WEB_ROOT|" $__XQD_PREFIX/.cfg
    echo -e "#!/bin/bash\\n#By xiaoqidun@gmail.com\\nexport PATH=$PATH:$__XQD_PREFIX/sbin:$__XQD_PREFIX/init:$NGINX_PREFIX/sbin:$MYSQL_PREFIX/bin:$PGSQL_PREFIX/bin:$PHP_PREFIX/bin:$PHP_PREFIX/sbin\\n/bin/bash" > $__XQD_PREFIX/sbin/shell 2>&1
    test -f $__XQD_PREFIX/sbin/shell && chmod 0700 $__XQD_PREFIX/sbin/shell 2>> /dev/null && ln -s $__XQD_PREFIX/sbin/shell /usr/local/sbin/lnmpp.shell 2>> /dev/null
}
check_root() {
    if test $(id -u) != "0" || test $(id -g) != 0 ; then
        echo Root run $0 ?
        exit
    fi
}
user_group() {
    id $PHPFPM_USER >> /dev/null 2>&1
    if test "$?" = "1" ; then
        useradd $PHPFPM_USER >> /dev/null 2>&1
    fi
    id $NGINX_USER >> /dev/null 2>&1
    if test "$?" = "1" ; then
        useradd $NGINX_USER >> /dev/null 2>&1
    fi
    if test "$DISABLE_MYSQL" = "1" ; then
        id $MYSQL_USER >> /dev/null 2>&1
        if test "$?" = "1" ; then
            useradd $MYSQL_USER >> /dev/null 2>&1
        fi
    fi
    if test "$DISABLE_POSTGRESQL" = "1" ; then
        id $PGSQL_USER >> /dev/null 2>&1
        if test "$?" = "1" ; then
            useradd $PGSQL_USER >> /dev/null 2>&1
        fi
    fi
    if cat /proc/mounts | grep -on "\ /system\ " >> /dev/null 2>&1 && cat /proc/mounts | grep -on "\ /data\ " >> /dev/null 2>&1 ; then
        usermod -a -G 3003 $PHPFPM_USER >> /dev/null 2>&1
        usermod -a -G 3003 $NGINX_USER >> /dev/null 2>&1
        test "$DISABLE_MYSQL" = "1" && usermod -a -G 3003 $MYSQL_USER >> /dev/null 2>&1
        test "$DISABLE_POSTGRESQL" = "1" && usermod -a -G 3003 $PGSQL_USER >> /dev/null 2>&1
    fi
    usermod -a -G $PHPFPM_GROUP $NGINX_USER >> /dev/null 2>&1
}
helloworld() {
    vvv=$(echo $OS_VER | awk -F '.' '{print$1}')
    cat <<HELLOWORLD
-----------------------------
Web: https://aite.xyz/
Lnmpp: $VER for $OS $vvv
Qq:88966001 Qgroup:38181604 
Author: xiaoqidun@gmail.com
Linux nginx mysql pgsql php
-----------------------------
HELLOWORLD
}
pkg_install() {
    case "$OS" in
        "debian")
            APT_1="libpcre3-dev"
            APT_2="libncurses5-dev libreadline-dev"
            APT_3="libxslt1-dev libbz2-dev libmcrypt-dev libgmp3-dev libcurl4-openssl-dev"
            if test $(echo $OS_VER | awk -F '.' '{print$1}') > 9 ; then
                APT_4="libgd-dev"
            else
                APT_4="libgd2-xpm-dev"
            fi
            LIBSSL=libssl-dev
            echo -n "Debian apt update "
            bg_wait apt-get update
            if test $(cat $BGEXEC_EXIT_STATUS_FILE) != "0" ; then
                echo -ne fail\\n
            else
                echo -ne done\\n
            fi
            echo -n "Debian apt install "
            DEBIAN_FRONTEND=noninteractive bg_wait apt-get -qqy --force-yes install cmake autoconf pkg-config locales-all build-essential $LIBSSL $APT_1 $APT_2 $APT_3 $APT_4
            if test $(cat $BGEXEC_EXIT_STATUS_FILE) != "0" ; then
                echo -ne fail\\n-----------------------------\\n
                exit
            fi
            ! test -d /usr/include/curl && ln -s $(find /usr/include/ -name curl) /usr/include/curl >> /dev/null 2>&1
            ! test -f /usr/include/gmp.h && ln -s $(find /usr/include/ -name gmp.h) /usr/include/gmp.h >> /dev/null 2>&1
            echo -ne done\\n-----------------------------\\n
        ;;
        "centos")
            YUM_0="wget bzip2"
            YUM_1="pcre-devel openssl-devel"
            YUM_2="ncurses-devel readline-devel"
            YUM_3="gd-devel gmp-devel bzip2-devel libxslt-devel libcurl-devel"
            echo -n "Centos yum install "
            bg_wait yum -q -y install gcc gcc-c++ cmake autoconf $YUM_0 $YUM_1 $YUM_2 $YUM_3
            if test $(cat $BGEXEC_EXIT_STATUS_FILE) != "0" ; then
                echo -ne fail\\n-----------------------------\\n
                exit
            fi
            echo -ne done\\n-----------------------------\\n
        ;;
        "ubuntu")
            APT_1="libpcre3-dev libssl-dev"
            APT_2="libncurses5-dev libreadline-dev"
            APT_3="libxslt1-dev libbz2-dev libmcrypt-dev libgmp3-dev libgd2-xpm-dev libcurl4-openssl-dev"
            echo -n "Ubuntu apt update "
            bg_wait apt-get update
            if test $(cat $BGEXEC_EXIT_STATUS_FILE) != "0" ; then
                echo -ne fail\\n
            else
                echo -ne done\\n
            fi
            echo -n "Ubuntu apt install "
            DEBIAN_FRONTEND=noninteractive bg_wait apt-get -qqy --force-yes install cmake autoconf pkg-config build-essential $APT_1 $APT_2 $APT_3
            if test $(cat $BGEXEC_EXIT_STATUS_FILE) != "0" ; then
                echo -ne fail\\n-----------------------------\\n
                exit
            fi
            ! test -f /usr/include/gmp.h && ln -s $(find /usr/include/ -name gmp.h) /usr/include/gmp.h >> /dev/null 2>&1
            echo -ne done\\n-----------------------------\\n
        ;;
    esac
}
src_install() {
    if test -n "$1" ; then
        case "$1" in
            "_php_")
                cd $PHP_SRC_DIR
                rm -f configure 2>> /dev/null
                ./buildconf --force >> /dev/null 2>&1 &
                echo -n Build php configure\ ;wait_pid $!
                if test -x $PHP_SRC_DIR/configure ; then
                    echo -ne done\\n
                else
                    echo -ne fail\\n
                    exit
                fi
                src_configure php >> /dev/null 2>&1 &
                echo -n Configure php\ ;wait_pid $!
                if test -f $PHP_SRC_DIR/Makefile ; then
                    echo -ne done\\n
                else
                    echo -ne fail\\n
                    exit
                fi
                make $MAKE_J >> /dev/null 2>&1 &
                echo -n Make php\ ;wait_pid $!
                if test -x $PHP_SRC_DIR/sapi/fpm/php-fpm ; then
                    echo -ne done\\n
                else
                    echo -ne fail\\n
                    exit
                fi
                make install >> /dev/null 2>&1 &
                echo -n Make install php\ ;wait_pid $!
                if test -x $PHP_PREFIX/bin/php ; then
                    echo -ne done\\n
                else
                    echo -ne fail\\n
                    exit
                fi
            ;;
            "nginx")
                cd $NGINX_SRC_DIR
                src_configure $1 >> /dev/null 2>&1 &
                echo -n Configure nginx\ ;wait_pid $!
                if test -f $NGINX_SRC_DIR/objs/Makefile ; then
                    echo -ne done\\n
                else
                    echo -ne fail\\n
                    exit
                fi
                make $MAKE_J >> /dev/null 2>&1 &
                echo -n Make nginx\ ;wait_pid $!
                if test -x $NGINX_SRC_DIR/objs/nginx ; then
                    echo -ne done\\n
                else
                    echo -ne fail\\n
                    exit
                fi
                make install >> /dev/null 2>&1 &
                echo -n Make install nginx\ ;wait_pid $!
                if test -x $NGINX_PREFIX/sbin/nginx ; then
                    echo -ne done\\n
                else
                    echo -ne fail\\n
                    exit
                fi
            ;;
            "mysql")
                cd $MYSQL_SRC_DIR
                src_configure $1 >> /dev/null 2>&1 &
                echo -n Cmake mysql\ ;wait_pid $!
                if test -f $MYSQL_SRC_DIR/Makefile ; then
                    echo -ne done\\n
                else
                    echo -ne fail\\n
                    exit
                fi
                make $MAKE_J >> /dev/null 2>&1 &
                echo -n Make mysql\ ;wait_pid $!
                if test -x $MYSQL_SRC_DIR/mysql-test/lib/My/SafeProcess/my_safe_process ; then
                    echo -ne done\\n
                else
                    echo -ne fail\\n
                    exit
                fi
                make install >> /dev/null 2>&1 &
                echo -n Make install mysql\ ;wait_pid $!
                if test -x $MYSQL_PREFIX/bin/mysqld_safe ; then
                    echo -ne done\\n
                else
                    echo -ne fail\\n
                    exit
                fi
            ;;
            "pgsql")
                cd $PGSQL_SRC_DIR
                src_configure $1 >> /dev/null 2>&1 &
                echo -n Configure postgresql\ ;wait_pid $!
                if test -f $PGSQL_SRC_DIR/src/Makefile ; then
                    echo -ne done\\n
                else
                    echo -ne fail\\n
                    exit
                fi
                make $MAKE_J >> /dev/null 2>&1 &
                echo -n Make postgresql\ ;wait_pid $!
                if test -x $PGSQL_SRC_DIR/src/test/regress/pg_regress ; then
                    echo -ne done\\n
                else
                    echo -ne fail\\n
                    exit
                fi
                make install >> /dev/null 2>&1 &
                echo -n Make install postgresql\ ;wait_pid $!
                if test -x $PGSQL_PREFIX/bin/postgres ; then
                    echo -ne done\\n
                else
                    echo -ne fail\\n
                    exit
                fi
            ;;
            "libmcrypt")
                cd $LIBMCRYPT_SRC_DIR
                src_configure $1 >> /dev/null 2>&1 &
                echo -n Configure libmcrypt\ ;wait_pid $!
                if test -f $LIBMCRYPT_SRC_DIR/lib/Makefile ; then
                    echo -ne done\\n
                else
                    echo -ne fail\\n
                    exit
                fi
                make $MAKE_J >> /dev/null 2>&1 &
                echo -n Make libmcrypt\ ;wait_pid $!
                if test -f $LIBMCRYPT_SRC_DIR/lib/.libs/libmcrypt.so.4.4.8 ; then
                    echo -ne done\\n
                else
                    echo -ne fail\\n
                    exit
                fi
                make install >> /dev/null 2>&1 &
                echo -n Make install libmcrypt\ ;wait_pid $!
                if test -x $LIBMCRYPT_PREFIX/bin/libmcrypt-config ; then
                    echo -ne done\\n
                else
                    echo -ne fail\\n
                    exit
                fi
            ;;
        esac
    fi
}
config_init() {
    if test -n "$1" ; then
        case "$1" in
            "_php_")
                echo -n Php config file init ....
                mkdir -p $PHP_PREFIX/var/sock 2>> /dev/null
                mkdir -p $PHP_PREFIX/etc/fpm.d 2>> /dev/null
                cp $ETC/p_tpl.conf $PHP_PREFIX/etc/fpm.d/default.conf
                sed -i "s|{NAME}|default|" $PHP_PREFIX/etc/fpm.d/default.conf
                sed -i "s|{NGINX_USER}|$NGINX_USER|" $PHP_PREFIX/etc/fpm.d/default.conf
                sed -i "s|{NGINX_GROUP}|$NGINX_GROUP|" $PHP_PREFIX/etc/fpm.d/default.conf
                sed -i "s|{PHPFPM_USER}|$PHPFPM_USER|" $PHP_PREFIX/etc/fpm.d/default.conf
                sed -i "s|{PHPFPM_GROUP}|$PHPFPM_GROUP|" $PHP_PREFIX/etc/fpm.d/default.conf
                sed -i "s|{ROOT}|$NGINX_DEFAULT_WEB_ROOT|" $PHP_PREFIX/etc/fpm.d/default.conf
                echo -e "[global]\\npid = run/php-fpm.pid\\ninclude = etc/fpm.d/*.conf" > $PHP_PREFIX/etc/php-fpm.conf 2>> /dev/null
                cp $PHP_SRC_DIR/php.ini-production $PHP_PREFIX/lib/php.ini
                sed -i '/^; Local/,/^; End/d' $PHP_PREFIX/lib/php.ini
                sed -i "s|^short_open_tag = Off|short_open_tag = On|" $PHP_PREFIX/lib/php.ini
                sed -i "s|^post_max_size = 8M|post_max_size = 64M|" $PHP_PREFIX/lib/php.ini
                sed -i "s|^upload_max_filesize = 2M|upload_max_filesize = 64M|" $PHP_PREFIX/lib/php.ini
                sed -i "s|^;date.timezone =|date.timezone = PRC|" $PHP_PREFIX/lib/php.ini
                sed -i "s|^; If you wish to have an extension|zend_extension=opcache.so\\n\\n; If you wish to have an extension|" $PHP_PREFIX/lib/php.ini
                cp -a $PHP_SRC_DIR/sapi/fpm/init.d.php-fpm $__XQD_PREFIX/init/phpfpm >> /dev/null 2>&1
                chmod 0755 $__XQD_PREFIX/init/phpfpm
                echo -ne \\b\\b\\b\\bdone\\n
            ;;
            "nginx")
                echo -n Nginx config file init ....
                cp $ETC/nginx.conf $NGINX_PREFIX/conf
                sed -i "s|{NGINX_USER}|$NGINX_USER|" $NGINX_PREFIX/conf/nginx.conf
                chown 0:0 $NGINX_PREFIX/conf/nginx.conf
                chmod 0644 $NGINX_PREFIX/conf/nginx.conf
                mkdir -p $NGINX_PREFIX/conf/server
                cp $ETC/n_tpl.conf $NGINX_PREFIX/conf/server/default.conf
                sed -i "s|80|80 default|" $NGINX_PREFIX/conf/server/default.conf
                sed -i "s|{SOCKET_NAME}|default|" $NGINX_PREFIX/conf/server/default.conf
                sed -i "s|{SERVER_NAME}|localhost|" $NGINX_PREFIX/conf/server/default.conf
                sed -i "s|{PHP_PREFIX}|$PHP_PREFIX|" $NGINX_PREFIX/conf/server/default.conf
                sed -i "s|{ROOT}|$NGINX_DEFAULT_WEB_ROOT|" $NGINX_PREFIX/conf/server/default.conf
                mkdir -p $NGINX_DEFAULT_WEB_ROOT -m 0750
                chown $PHPFPM_USER:$PHPFPM_GROUP $NGINX_DEFAULT_WEB_ROOT
                echo -ne \\b\\b\\b\\bdone\\n
            ;;
            "mysql")
                echo -n Mysql config file init ....
                cd $MYSQL_PREFIX
                test "$OS" = "centos" && test -f /etc/my.cnf && mv /etc/my.cnf /etc/my.cnf.bak 2>> /dev/null
                scripts/mysql_install_db --user=$MYSQL_USER >> /dev/null 2>&1
                if test "$?" != 0 || ! test -d $MYSQL_PREFIX/data/mysql ; then
                    echo -ne \\b\\b\\b\\bfail\\n
                    exit
                fi
                test -f $MYSQL_PREFIX/my.cnf && echo -e "\\ntable_open_cache = 128\\ntable_definition_cache = 256\\nperformance_schema_max_table_instances = 256" >> $MYSQL_PREFIX/my.cnf 2>> /dev/null
                $MYSQL_PREFIX/support-files/mysql.server start >> /dev/null 2>&1
                $MYSQL_PREFIX/support-files/mysql.server status >> /dev/null 2>&1
                if test "$?" != "0" ; then
                    echo -ne \\b\\b\\b\\bfail\\n
                    exit
                fi
                $MYSQL_PREFIX/bin/mysqladmin -u root password "$MYSQL_DEFAULT_PASSWORD" >> /dev/null 2>&1
                if test "$?" != "0" ; then
                    echo -ne \\b\\b\\b\\bfail\\n
                    exit
                fi
                $MYSQL_PREFIX/support-files/mysql.server stop >> /dev/null 2>&1
                cp -a $MYSQL_PREFIX/support-files/mysql.server $__XQD_PREFIX/init/mysql >> /dev/null 2>&1
                echo -ne \\b\\b\\b\\bdone\\n
            ;;
            "pgsql")
                echo -n Postgresql config file init ....
                cd $PGSQL_PREFIX
                mkdir -p $PGSQL_PREFIX/log
                mkdir -p $PGSQL_PREFIX/data
                chown $PGSQL_USER:$PGSQL_GROUP $PGSQL_PREFIX/log
                chown $PGSQL_USER:$PGSQL_GROUP $PGSQL_PREFIX/data
                cat > $PGSQL_PREFIX/postgres_pw <<<"$POSTGRESQL_DEFAULT_PASSWORD"
                su -c "$PGSQL_PREFIX/bin/initdb --pwfile=$PGSQL_PREFIX/postgres_pw -A md5 -E UTF8 -D $PGSQL_PREFIX/data" postgres >> /dev/null 2>&1
                if test "$?" = 1 || ! test -f $PGSQL_PREFIX/data/postgresql.conf ; then
                    echo -ne \\b\\b\\b\\bfail\\n
                    exit
                fi
                rm -f $PGSQL_PREFIX/postgres_pw
                echo -ne \\b\\b\\b\\bdone\\n
            ;;
        esac
    fi
}
global_init() {
    case "$1" in
        "binary")
            mkdir -p $NGINX_DEFAULT_WEB_ROOT -m 0750
            echo -e "<?php\\nphpinfo();\\n?>" > $NGINX_DEFAULT_WEB_ROOT/index.php 2>&1
            chmod 0640 $NGINX_DEFAULT_WEB_ROOT/index.php 2>> /dev/null
            chown -R $PHPFPM_USER:$PHPFPM_GROUP $NGINX_DEFAULT_WEB_ROOT/ >> /dev/null 2>&1
            if test "$DISABLE_MYSQL" = "1" ; then
                test "$OS" = "centos" && test -f /etc/my.cnf && mv /etc/my.cnf /etc/my.cnf.bak 2>> /dev/null
                test "$OS" = "centos" && test -f /var/lock/subsys/mysql && rm -f /var/lock/subsys/mysql 2>> /dev/null
            fi
            test -x $__XQD_PREFIX/sbin/shell && ln -s $__XQD_PREFIX/sbin/shell /usr/local/sbin/lnmpp.shell 2>> /dev/null
        ;;
        *)
            cp -r $WWW/* $NGINX_DEFAULT_WEB_ROOT/ >> /dev/null 2>&1
            echo -e "<?php\\nphpinfo();\\n?>" > $NGINX_DEFAULT_WEB_ROOT/index.php 2>&1
            chmod 0640 $NGINX_DEFAULT_WEB_ROOT/index.php 2>> /dev/null
            chown -R $PHPFPM_USER:$PHPFPM_GROUP $NGINX_DEFAULT_WEB_ROOT/* >> /dev/null 2>&1
        ;;
    esac
    case "$OS" in
        "debian")
            ln -s $__XQD_PREFIX/init/lnmpp /etc/init.d/lnmpp >> /dev/null 2>&1
            insserv -d lnmpp 2>> /dev/null
        ;;
        "ubuntu")
            ln -s $__XQD_PREFIX/init/lnmpp /etc/init.d/lnmpp >> /dev/null 2>&1
            update-rc.d lnmpp defaults >> /dev/null 2>&1
        ;;
        "centos")
            ln -s $__XQD_PREFIX/init/lnmpp /etc/init.d/lnmpp >> /dev/null 2>&1
            chkconfig lnmpp on >> /dev/null 2>&1
            CENTOS_VER_ID=$(echo $OS_VER | awk -F '.' '{print$1}') >> /dev/null 2>&1
            case "$CENTOS_VER_ID" in
                "7")
                    firewall-cmd --permanent --zone=public --add-port=80/tcp >> /dev/null 2>&1
                    firewall-cmd --reload >> /dev/null 2>&1
                ;;
                "6")
                    iptables -I INPUT -p tcp --dport 80 -j ACCEPT >> /dev/null 2>&1
                    service iptables save >> /dev/null 2>&1
                ;;
            esac
        ;;
    esac
    which systemctl >> /dev/null 2>&1 && systemctl daemon-reload >> /dev/null 2>&1
    service lnmpp start >> /dev/null 2>&1
    echo -e -----------------------------\\nAll Installation Complete\\n-----------------------------\\nProcessed\ in\ $(awk "BEGIN{print `date +%s`-$init_date}")\ second\(s\)
}
tar_extract() {
    if ! test -d $NGINX_SRC_DIR ; then
        echo -n +Extract nginx ....
        tar -axf $NGINX_TAR_SRC -C $SRC >> /dev/null 2>&1
        if ! test -d $NGINX_SRC_DIR ; then
            echo -ne \\b\\b\\b\\bfail\\n
            exit
        else
            echo -ne \\b\\b\\b\\bdone\\n
        fi
    fi
    if ! test -d $MYSQL_SRC_DIR && test "$DISABLE_MYSQL" = "1" ; then
        echo -n +Extract mysql ....
        tar -axf $MYSQL_TAR_SRC -C $SRC >> /dev/null 2>&1
        if ! test -d $MYSQL_SRC_DIR ; then
            echo -ne \\b\\b\\b\\bfail\\n
            exit
        else
            echo -ne \\b\\b\\b\\bdone\\n
        fi
    fi
    if ! test -d $PGSQL_SRC_DIR && test "$DISABLE_POSTGRESQL" = "1" ; then
        echo -n +Extract pgsql ....
        tar -axf $PGSQL_TAR_SRC -C $SRC >> /dev/null 2>&1
        if ! test -d $PGSQL_SRC_DIR ; then
            echo -ne \\b\\b\\b\\bfail\\n
            exit
        else
            echo -ne \\b\\b\\b\\bdone\\n
        fi
    fi
    if ! test -d $PHP_SRC_DIR ; then
        echo -n +Extract _php_ ....
        tar -axf $PHP_TAR_SRC -C $SRC >> /dev/null 2>&1
        if ! test -d $PHP_SRC_DIR ; then
            echo -ne \\b\\b\\b\\bfail\\n
            exit
        else
            echo -ne \\b\\b\\b\\bdone\\n
        fi
    fi
    if ! test -d $LIBMCRYPT_SRC_DIR && test "$OS" = "centos" ; then
        echo -n +Extract libmcrypt ....
        tar -axf $LIBMCRYPT_TAR_SRC -C $SRC >> /dev/null 2>&1
        if ! test -d $LIBMCRYPT_SRC_DIR ; then
            echo -ne \\b\\b\\b\\bfail\\n
            exit
        else
            echo -ne \\b\\b\\b\\bdone\\n
        fi
    fi
}
xqd_extract() {
    file=xiaoqidun.tar.bz2
    sha1=a86d8e91bb325daa1bf5810d7a7625edf32d32ed
    if test -f $file && test "$(sha1sum $file | awk '{print$1}')" = "$sha1" ; then
        tar -jxf $file >> /dev/null 2>&1 &
        echo -n +Extract lnmpp package\ ;wait_pid $!
        if test -d $XPWD/xiaoqidun ; then
            echo -ne done\\n-----------------------------\\n
        else
            echo -ne fail\\n-----------------------------\\n
        fi
    else
        test -f $file && rm -f $file 2>> /dev/null
        wget -q -T 120 -O $file http://lnmpp.aite.xyz/$file >> /dev/null 2>&1 &
        echo -n Download lnmpp package\ ;wait_pid $!
        if test -f $file && test "$(sha1sum $file | awk '{print$1}')" = "$sha1" ; then
            echo -ne done\\n-----------------------------\\n
            xqd_extract
        else
            echo -ne fail\\n-----------------------------\\n
            exit
        fi
    fi
}
bin_extract() {
    file=`bin_file`
    sha1=`bin_sha1`
    if test -f $file && test "$(sha1sum $file | awk '{print$1}')" = "$sha1" ; then
        tar -jxf $file -C $BIN_PREFIX >> /dev/null 2>&1 &
        echo -n Lnmpp binary install\ ;wait_pid $!
        if test -x $BIN_PREFIX/_xqd_/init/lnmpp && test $($BIN_PREFIX/_xqd_/init/lnmpp status 2>> /dev/null | wc -l) = "5" ; then
            echo -ne done\\n
        else
            echo -ne fail\\n
            exit
        fi
    else
        test -f $file && rm -f $file 2>> /dev/null
        wget -q -T 120 -O $file http://lnmpp.aite.xyz/$file >> /dev/null 2>&1 &
        echo -n Download lnmpp package\ ;wait_pid $!
        if test -f $file && test "$(sha1sum $file | awk '{print$1}')" = "$sha1" ; then
            echo -ne done\\n-----------------------------\\n
            bin_extract
        else
            echo -ne fail\\n-----------------------------\\n
            exit
        fi
    fi
}
sfx_extract() {
    input=$(which $0)
    output="data.tmp"
    sed -n "/^aite[.]xyz/,$ p" $input | sed "1d" > $output
    if test "$(sha1sum $output | awk '{print$1}')" != "" ; then
        echo Sfx unpack data error
        rm -f $output
        exit
    else
        cd $XPWD
        tar -jxf $output >> /dev/null 2>&1
        rm $output
    fi
}
xqd_download() {
    if ! test -f $PHP_TAR_SRC || ! test -f $NGINX_TAR_SRC || ! test -f $MYSQL_TAR_SRC || ! test -f $PGSQL_TAR_SRC ; then
        src_download $NGINX_TAR_SRC $NGINX_TAR_SRC_URL "Download nginx "
        src_download $MYSQL_TAR_SRC $MYSQL_TAR_SRC_URL "Download mysql "
        src_download $PGSQL_TAR_SRC $PGSQL_TAR_SRC_URL "Download pgsql "
        src_download $PHP_TAR_SRC $PHP_TAR_SRC_URL "Download _php_ "
        echo -----------------------------
    fi
}
src_download() {
    if ! test -f $1 ; then
        echo -n "$3"
        bg_wait wget -q -T 120 -O ${1}_tmp $2
        if test $(cat $BGEXEC_EXIT_STATUS_FILE) != "0" || ! test -f ${1}_tmp ; then
            echo -ne fail\\n
            test -f ${1}_tmp && rm -f ${1}_tmp && exit 2
        else
            echo -ne done\\n
            mv ${1}_tmp ${1}
        fi
    fi
}
src_configure() {
    if test -n "$1" ; then
        case "$1" in
            "php")
                $PHP_CONFIGURE
            ;;
            "nginx")
                $NGINX_CONFIGURE
            ;;
            "mysql")
                $MYSQL_CONFIGURE
            ;;
            "pgsql")
                $PGSQL_CONFIGURE
            ;;
            "libmcrypt")
                $LIBMCRYPT_CONFIGURE
            ;;
        esac
    fi
}
path
VER=1.9
for((i=1;i<=$#;i++)); do
    ini_cfg=${!i}
    ini_cfg_a=`echo $ini_cfg | sed -r s/^-?-?.*=//`
    ini_cfg_b=`echo $ini_cfg | grep -o -E ^-?-?[a-z]+`
    init_exec "$ini_cfg_b" "$ini_cfg_a"
done
init $@
exit
aite.xyz
