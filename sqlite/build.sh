#!/bin/bash
# This is a buildpkg build.sh script
# build.sh helper functions
. ${BUILDPKG_SCRIPTS}/build.sh.functions
#
###########################################################
# Check the following 4 variables before running the script
topdir=sqlite
version=3.8.10.2
shortver=3081002
pkgver=1
source[0]=http://www.sqlite.org/2015/sqlite-autoconf-${shortver}.tar.gz
# If there are no patches, simply comment this
#patch[0]=

# Source function library
. ${BUILDPKG_SCRIPTS}/buildpkg.functions

# Global settings
export CFLAGS="-O2 -g -DSQLITE_HOMEGROWN_RECURSIVE_MUTEX -D__EXTENSIONS__"
export CPPFLAGS="-I$prefix/include"
export LDFLAGS="-L$prefix/lib -R$prefix/lib"
configure_args+=(--disable-static)
topsrcdir=sqlite-autoconf-${shortver}

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
    compat sqlite 3.8.8.3 1 1
    compat sqlite 3.8.10 1 1
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
