#!/bin/bash
# This is a buildpkg build.sh script
# build.sh helper functions
. ${BUILDPKG_SCRIPTS}/build.sh.functions
#
###########################################################
# Check the following 4 variables before running the script
topdir=nghttp2
version=1.41.0
pkgver=1
source[0]=https://github.com/${topdir}/${topdir}/releases/download/v${version}/${topdir}-${version}.tar.xz
# If there are no patches, simply comment this
#patch[0]=

# Source function library
. ${BUILDPKG_SCRIPTS}/buildpkg.functions

# Global settings
export CPPFLAGS="-I$prefix/include"
export LDFLAGS="-L$prefix/lib -R$prefix/lib"
configure_args+=(--disable-static --enable-lib-only)
make_build_target="V=1"
# No python deps from packaged scripts
ignore_deps="TGCpy27"
# No symbol visibility support
ac_overrides="ax_cv_check_cflags___fvisibility_hidden=no"
# gcc 4.x causes linking to fail despite building everything PIC:
# "ld: fatal: relocations remain against allocatable but non-writable sections"
# Rather than using -mimpure-text we drop back to gcc 3.4 since it just works
if [ "$arch" = "i386" ]; then
    export CC=/usr/tgcware/gcc34/bin/gcc
fi

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
    doc AUTHORS COPYING*
    ${__mv} ${stagedir}${prefix}/${_docdir}/${topdir}/README.rst ${stagedir}${prefix}/${_vdocdir}
    ${__rmdir} ${stagedir}${prefix}/${_docdir}/${topdir}
    ${__rmdir} ${stagedir}${prefix}/${_bindir}
    # manpages for tools that are not packaged
    ${__rm} -rf  ${stagedir}${prefix}/${_mandir}

    compat nghttp2 1.37.0 1 1
    compat nghttp2 1.38.0 1 1
    compat nghttp2 1.40.0 1 1
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
