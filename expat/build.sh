#!/bin/bash
# This is a buildpkg build.sh script
# build.sh helper functions
. ${BUILDPKG_SCRIPTS}/build.sh.functions
#
###########################################################
# Check the following 4 variables before running the script
topdir=expat
version=2.5.0
pkgver=1
source[0]=https://github.com/libexpat/libexpat/releases/download/R_2_5_0/${topdir}-${version}.tar.lz
# If there are no patches, simply comment this
patch[0]=expat-2.4.8-no-stdint_h.patch
patch[1]=expat-2.5.0-no-strtof.patch

# Source function library
. ${BUILDPKG_SCRIPTS}/buildpkg.functions

# Global settings
export LDFLAGS="-L/usr/tgcware/lib -R/usr/tgcware/lib"
export CPPFLAGS="-I/usr/tgcware/include"

reg prep
prep()
{
    generic_prep
}

reg build
build()
{
    generic_build
}

reg check
check()
{
    generic_check
}

reg install
install()
{
    generic_install DESTDIR
    doc COPYING Changes README.md AUTHORS doc/reference.html doc/expat.png doc/style.css
    ${__rm} -rf ${stagedir}${prefix}/share/doc/expat

    compat expat 2.1.0 1 1
    compat expat 2.2.5 1 1
    compat expat 2.2.9 1 1
    compat expat 2.4.8 1 1
}

reg pack
pack()
{
    generic_pack
}

reg distclean
distclean()
{
    clean distclean
}

###################################################
# No need to look below here
###################################################
build_sh $*
