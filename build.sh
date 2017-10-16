#!/bin/bash

CONFIG_DIR=`realpath $1`

set -e

if [ -z "${MATLAB_INSTALL_GLOB}"]; then
    if [ -f /etc/matlab/debconf ]; then
        source /etc/matlab/debconf
    fi
fi

TAG=`basename $CONFIG_DIR`

if [ -f $CONFIG_DIR/tag ]; then
    TAG=$(cat $CONFIG_DIR/tag)
fi

EXTENDS_S=`cat $CONFIG_DIR/extend`

SH_SCRIPT="""if [ -f /config/run.m ]; then cp /config/run.m /run.m; fi
/opt/matlab/bin/matlab -nodesktop -nosplash -r 'compile; exit;'
"""

if [ -f $CONFIG_DIR/packages_build ]; then
    BUILD_PACKAGES=$(cat $CONFIG_DIR/packages_build | tr '\n' ' ')
    SH_SCRIPT="apt-get update; apt-get -y install $BUILD_PACKAGES \n $SH_SCRIPT \n apt-get -y remove $BUILD_PACKAGES"
fi

if [ -f $CONFIG_DIR/packages_run ]; then
    RUN_PACKAGES=$(cat $CONFIG_DIR/packages_run | tr '\n' ' ')
    SH_SCRIPT="apt-get -y install $RUN_PACKAGES \n $SH_SCRIPT"
fi

SH_SCRIPT="apt-get update \n $SH_SCRIPT \n apt-get -y autoremove"

if [ ! -z "$APT_CACHE" ] ; then
    mkdir -p $APT_CACHE
    VOLUME_S="$VOLUME_S -v ${APT_CACHE}:/var/cache/apt/"
    SH_SCRIPT="$SH_SCRIPT && rm -rf /var/lib/apt/lists/"
else
    SH_SCRIPT="$SH_SCRIPT && apt-get clean && rm -rf /var/lib/apt/lists/"
fi

VOLUME_S="$VOLUME_S -v ${MATLAB_INSTALL_GLOB}:/opt/matlab:ro -v $CONFIG_DIR:/config:ro"
RUNDIR_S="-w /config"

if [ -f $CONFIG_DIR/environment ]; then
    ENV_S=$(cat $CONFIG_DIR/environment | sed 's/^/-e /g' | tr '\n' ' ' | sed "s/'//g")
fi

# Ensure container is stopped/removed when script finishes/aborts
CID=$(mktemp -u)
trap 'docker rm -f $(cat ${CID}) > /dev/null 2>&1' EXIT INT TERM HUP

docker run -t --cidfile=${CID} \
  ${ENV_S} ${VOLUME_S} ${RUNDIR_S} ${EXTENDS_S} \
  /bin/sh -c "echo \"${SH_SCRIPT}\" | /bin/bash" && \
  /bin/sh -c "docker commit --change='WORKDIR /' $(cat ${CID}) ${TAG:-}"

