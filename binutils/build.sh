#!/bin/bash
# This is a buildpkg build.sh script
# build.sh helper functions
. ${BUILDPKG_SCRIPTS}/build.sh.functions
#
###########################################################
# Check the following 4 variables before running the script
topdir=binutils
version=2.25
pkgver=1
source[0]=ftp://ftp.sunet.se/pub/gnu/binutils/$topdir-$version.tar.bz2
# If there are no patches, simply comment this
patch[0]=binutils-2.25-use-strtod-instead-of-strtold.patch

# Source function library
. ${BUILDPKG_SCRIPTS}/buildpkg.functions

# Global settings
export CPPFLAGS="-I$prefix/include"
export LDFLAGS="-L$prefix/lib -R$prefix/lib"
configure_args+=(--disable-werror --program-prefix=g)

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
    ${__rm} -f ${stagedir}${prefix}/${_mandir}/man1/g{dlltool,nlmconv,windres,windmc}*
    doc COPYING*
    compat binutils 2.18 1 1
    compat binutils 2.23.2 1 1
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
