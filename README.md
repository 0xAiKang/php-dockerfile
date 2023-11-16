
基于官方 PHP 镜像（Alpine Linux 的轻量级镜像）进行构建，镜像总大小在 160M 左右，生产环境可用。

安装了以下扩展：
```bash
[PHP Modules]
bcmath
bz2
calendar
Core
ctype
curl
date
dba
dom
exif
fileinfo
filter
ftp
gd
gettext
hash
iconv
imagick
imap
intl
json
libxml
mbstring
mongodb
mysqli
mysqlnd
openssl
pcntl
pcre
PDO
pdo_mysql
pdo_pgsql
pdo_sqlite
pgsql
Phar
posix
readline
redis
Reflection
session
SimpleXML
soap
sodium
SPL
sqlite3
standard
swoole
sysvmsg
sysvsem
sysvshm
tidy
tokenizer
xml
xmlreader
xmlwriter
xsl
Zend OPcache
zip
zlib

[Zend Modules]
Zend OPcache
```

### 手动构建镜像

构建镜像：
```bash
$ docker build -f php-7.4.33.Dockerfile . -t php:7.4.33
```

注意：
1. 如果宿主机所在环境，没有科学上网的条件，需要将 alpine 的镜像下载源替换为国内阿里云镜像站，否则构建速度会非常慢，且很可能会构建失败
2. 使用 pecl 安装swoole，默认是最新版本的，而最新版本需要 PHP 版本大于 8.0，因此不同版本的 PHP 里，指定安装不同版本的 Swoole

### 直接使用

拉取已经构建好的镜像：
```bash
$ docker pull hoooliday/php:7.4.33
```

### 如何在镜像中安装扩展

使用 `docker-php-ext-install` 命令，可以安装除 `mongodb`、`redis`、`swoole`、`xdebug`外的扩展：
```bash
$ docker-php-ext-install bcmath
```

使用 `pecl install` 安装 `mongodb`、`redis`、`swoole`、`xdebug`等扩展：
```bash
$ pecl install xdebug-3.0.3 && docker-php-ext-enable xdebug
```

使用 `docker-php-ext-enable`命令启用扩展。

手动安装扩展时，可能会缺少必要的构建工具和库，可以使用以下命令安装：
```bash
$ apk add --no-cache autoconf build-base 
```