#!/bin/bash
# This is a buildpkg build.sh script
# build.sh helper functions
. ${BUILDPKG_SCRIPTS}/build.sh.functions
#
###########################################################
# Check the following 4 variables before running the script
topdir=xz
version=5.2.1
pkgver=1
source[0]=http://tukaani.org/xz/$topdir-$version.tar.gz
# If there are no patches, simply comment this
#patch[0]=

# Source function library
. ${BUILDPKG_SCRIPTS}/buildpkg.functions

# Global settings
export CPPFLAGS="-I/usr/tgcware/lib"
export LDFLAGS="-L/usr/tgcware/lib -R/usr/tgcware/lib"
ac_overrides="gl_cv_posix_shell=/usr/bin/ksh"

reg prep
prep()
{
    generic_prep
    if [ "$arch" = "i386" ]; then
      # Replacing Wl,-z text with -mimpure-text is a workaround to avoid
      # "ld: fatal: relocations remain against allocatable but non-writable sections"
      # when linking liblzma
      setdir source
      sed -i 's|\${wl}-z \${wl}text|-mimpure-text|g' configure
    fi
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
    ${__mv} ${stagedir}${prefix}/${_docdir}/xz ${stagedir}${prefix}/${_vdocdir}
    compat xzutils 5.0.3 1 1
    compat xzutils 5.0.5 1 1
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
