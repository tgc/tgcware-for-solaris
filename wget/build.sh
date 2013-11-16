#!/bin/bash
# This is a buildpkg build.sh script
# build.sh helper functions
. ${BUILDPKG_SCRIPTS}/build.sh.functions
#
###########################################################
# Check the following 4 variables before running the script
topdir=wget
version=1.14
pkgver=1
source[0]=ftp://ftp.sunet.se/pub/gnu/wget/$topdir-$version.tar.xz
# If there are no patches, simply comment this
patch[0]=wget-1.14-fix-gnulib-locale_h.patch
patch[1]=wget-1.14-no-ipv6.patch
patch[2]=wget-1.14-fix-gnulib-sys_time.patch

# Source function library
. ${BUILDPKG_SCRIPTS}/buildpkg.functions

# Global settings
export CPPFLAGS="-I$prefix/include"
export LDFLAGS="-L$prefix/lib -R$prefix/lib"
configure_args+=(--with-ssl=openssl)

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
    doc AUTHORS COPYING NEWS README MAILING-LIST
    rmdir ${stagedir}${prefix}/lib
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
