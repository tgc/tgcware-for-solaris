#!/bin/bash
# This is a buildpkg build.sh script
# build.sh helper functions
. ${BUILDPKG_SCRIPTS}/build.sh.functions
#
###########################################################
# Check the following 4 variables before running the script
topdir=lzip
version=1.20
pkgver=1
source[0]=http://download.savannah.gnu.org/releases/lzip/$topdir-$version.tar.gz
# If there are no patches, simply comment this
patch[0]=lzip-1.20-no-stdint_h.patch

# Source function library
. ${BUILDPKG_SCRIPTS}/buildpkg.functions

# Global settings
LDFLAGS="-L/usr/tgcware/lib -R/usr/tgcware/lib"
configure_args+=(LDFLAGS="$LDFLAGS")

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
    doc NEWS README AUTHORS COPYING
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
