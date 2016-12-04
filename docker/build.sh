#!/bin/bash

set -x

# Tool versions
declare -A VERS
VERS[snakemake]=3.8.2
VERS[khmer]=2.0
VERS[skbio]=0.5.1
VERS[ete3]=3.0.0b36
VERS[scrm]=1.7.2
VERS[mason2]=2.0.5
VERS[dawg]=f9ebcd8cff   # This commit was the dev HEAD for initial experiments
VERS[trimit]=0.2.5


apt-get update
apt-get upgrade -yy
apt-get install -yy           \
 curl                         \
 build-essential              \
 cmake                        \
 pkg-config                   \
 libboost-dev                 \
 libboost-program-options-dev \
 libbz2-dev                   \
 libgsl-dev                   \
 zlib1g-dev                   \
 python3-dev                  \
 python3-pip                  \

# bison                        \
# flex                         \

pip3 install cython     \
             numpy      \
             scipy      \
             matplotlib \
             docopt     \

pip3 install --pre                         \
             snakemake==${VERS[snakemake]} \
             khmer==${VERS[khmer]}         \
             scikit-bio=${VERS[khmer]}     \
             ete3==${VERS[ete3]}           \

################################################################################
#                            Source/binary tarballs                            #
################################################################################


cd /usr/local/src


##########
#  SCRM  #
##########

# Downloads static binary directly
curl -LS -o /usr/local/bin/scrm \
    https://github.com/scrm/scrm/releases/download/v${VERS[scrm]}/scrm-x64-static


############
#  Mason2  #
############

curl -LSO http://packages.seqan.de/mason2/mason2-${VERS[mason2]}-Linux-x86_64.tar.xz
tar xvf mason2-${VERS[mason2]}-Linux-x86_64.tar.xz
mv mason2-${VERS[mason2]}-Linux-x86_64/bin/* /usr/local/bin
rm -rf /usr/local/src/*


##############################
#  Dawg Development Release  #
##############################

tarname=dawg_${VERS[dawg]}.tar.gz 
# Install dawg2
curl -LS -o ${tarname}  \
    https://github.com/reedacartwright/dawg/archive/${VERS[dawg]}.tar.gz
tar xvf ${tarname}
cd dawg-${VERS[dawg]}*/
mkdir -p build && cd build
cmake .. -DCMAKE_INSTALL_PREFIX=..
make all install
mv ../bin/dawg /usr/local/bin/dawg2
cd ../..
rm -rf /usr/local/src/*
unset tarname

############
#  Trimit  #
############

curl -LSO \
    https://github.com/kdmurray91/libqcpp/releases/download/${VERS[trimit]}/trimit_${VERS[trimit]}_amd64.tar.gz

# extracts bin/trimit to /usr/local
tar xvf trimit_${VERS[trimit]}_amd64.tar.gz -C /usr/local --strip-components=1


##########
#  kWIP  #
##########

tarname=kwip_${VERS[kwip]}.tar.gz
curl -LS -o $tarname \
    https://github.com/kdmurray91/kWIP/archive/${VERS[kwip]}.tar.gz
tar xvf $tarname
cd kwip-${VERS[kwip]}/
mkdir build && cd build
cmake ..
make all install
rm -rf /usr/local/src/*

################################################################################
#                                   Cleanup                                    #
################################################################################

apt-get autoremove -y
apt-get clean -y
rm -rf /var/cache/apt/archives/* /var/lib/apt/lists/* /usr/share/locale/*
