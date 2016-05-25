#!/bin/bash
# This is a buildpkg build.sh script
# build.sh helper functions
. ${BUILDPKG_SCRIPTS}/build.sh.functions
#
###########################################################
# Check the following 4 variables before running the script
topdir=curl
version=7.49.0
pkgver=1
source[0]=http://curl.haxx.se/download/$topdir-$version.tar.bz2
# If there are no patches, simply comment this
#patch[0]=

# Source function library
. ${BUILDPKG_SCRIPTS}/buildpkg.functions

# Global settings
export CPPFLAGS="-I$prefix/include"
export LDFLAGS="-L$prefix/lib -R$prefix/lib"

configure_args+=(--enable-static=no --enable-http --enable-ftp --enable-file --disable-ldap --enable-manual --disable-ipv6 --enable-cookies --enable-crypto --with-egd-socket=/var/run/egd-pool --with-libidn)

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
    doc CHANGES COPYING README* RELEASE-NOTES docs/FAQ docs/FEATURES docs/BUGS \
      docs/MANUAL docs/RESOURCES docs/TODO docs/TheArtOfHttpScripting \
      docs/examples/*.c docs/examples/Makefile.example docs/INTERNALS \
      docs/CONTRIBUTE

    # ABI compatible releases
    compat curl 7.19.4 1 5
    compat curl 7.20.1 1 5
    compat curl 7.21.6 1 1
    compat curl 7.33.0 1 1
    compat curl 7.36.0 1 1
    compat curl 7.37.1 1 1
    compat curl 7.38.1 1 1
    compat curl 7.41.0 1 1
    compat curl 7.42.0 1 1
    compat curl 7.42.1 1 1
    compat curl 7.44.0 1 1
    compat curl 7.45.0 1 1
    compat curl 7.46.0 1 1
    compat curl 7.47.1 1 2
    compat curl 7.48.0 1 1
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
