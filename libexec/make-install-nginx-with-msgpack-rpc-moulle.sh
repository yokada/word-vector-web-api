#!/usr/bin/env bash

# Copyright (C) 2015 Toshinori Sato (@overlast)
#
#       https://github.com/overlast/word-vector-web-api
#
# Licensed under the Apache License, Version 2.0 (the &quot;License&quot;);
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#       http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an &quot;AS IS&quot; BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

#set -x # show executed commands
set -e # die when an error will occur

BASEDIR=`cd $(dirname $0); pwd`
USER_ID=`/usr/bin/id -u`
ECHO_PREFIX="[make-install-nginx-with-msgpack-rpc-moulle] : "

TMPDIR=/var/tmp/nginx-with-msgpack-rpc-module

NGX_VERSION=1.8.0
NGX_DIR_NAME=nginx-${NGX_VERSION}

NGX_DIR=nginx-with-msgpack-rpc-module
INSTALL_DIR=/usr/local/${NGX_DIR}

NGX_MODULE_DIR=${TMPDIR}/nginx-msgpack-rpc-module
ECHO_MODULE_DIR=${TMPDIR}/echo-nginx-module

echo "${ECHO_PREFIX} Get sudo password"
sudo pwd

echo "${ECHO_PREFIX} nginx will install to ${INSTALL_DIR}."

while true;do
    echo "${ECHO_PREFIX} nginx will install to ${INSTALL_DIR}."
    echo "${ECHO_PREFIX} Type 'yes|y' or 'dir path which you want to install'."
    read answer
    case $answer in
        yes)
            echo -e "${ECHO_PREFIX} [yes]\n"
            echo -e "${ECHO_PREFIX} nginx will install to ${INSTALL_DIR}.\n"
            break
            ;;
        y)
            echo -e "${ECHO_PREFIX} [y]\n"
            echo -e "${ECHO_PREFIX} nginx will install to ${INSTALL_DIR}.\n"
            break
            ;;
        *)
            echo -e "${ECHO_PREFIX} [$answer]\n"
            INSTALL_DIR=$answer
            echo -e "${ECHO_PREFIX} instll dir is changed.\n"
            ;;
    esac
done

if [ ! -e /usr/local/lib/libmsgpack_rpc_client.so.0.0.1 ]; then
    echo "${ECHO_PREFIX} msgpack-rpc-c must be installed.."

    if [ "$(uname)" == 'Darwin' ]; then
        echo "$SCRIPT_NAME OSX is supported"
        $BASEDIR/../libexec/make_osx_env.sh
    elif [ "$(expr substr $(uname -s) 1 5)" == 'Linux' ]; then
        echo "$SCRIPT_NAME Linux is supported"
        $BASEDIR/../libexec/make_centos_env.sh
    else
        echo "$SCRIPT_NAME Your platform ($(uname -a)) isn't supported"
        exit 1
    fi
fi

echo "${ECHO_PREFIX} cd to tmp dir"
if [ -e ${TMPDIR} ]; then
    rm -rf ${TMPDIR}
fi
mkdir -p ${TMPDIR}
cd ${TMPDIR}

git clone https://github.com/overlast/nginx-msgpack-rpc-module.git
git clone https://github.com/openresty/echo-nginx-module.git

wget http://nginx.org/download/${NGX_DIR_NAME}.tar.gz
tar xfvz ./${NGX_DIR_NAME}.tar.gz
cd ${NGX_DIR_NAME}

./configure --add-module=${ECHO_MODULE_DIR} --add-module=${NGX_MODULE_DIR} --prefix=${INSTALL_DIR}

${NGX_MODULE_DIR}/bin/fix_makefile.pl ./objs/Makefile
make
sudo make install

echo "${ECHO_PREFIX} Finish.."

echo "${ECHO_PREFIX} nginx.conf is here => ${INSTALL_DIR}/conf/nginx.conf"
echo ""
echo "${ECHO_PREFIX} nginx with msgpack_rpc_module can start to exec ${INSTALL_DIR}/sbin/nginx"
echo "Usage :"
echo "  Start                     : ${INSTALL_DIR}/sbin/nginx"
echo "  Stop                      : ${INSTALL_DIR}/sbin/nginx -s stop"
echo "  Quit after fetch request  : ${INSTALL_DIR}/sbin/nginx -s quit"
echo "  Reopen the logfiles       : ${INSTALL_DIR}/sbin/nginx -s reopen"
echo "  Reload nginx.conf         : ${INSTALL_DIR}/sbin/nginx -s reloqd"
echo
