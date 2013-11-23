#!/bin/bash
# This is a buildpkg build.sh script
# build.sh helper functions
. ${BUILDPKG_SCRIPTS}/build.sh.functions
#
###########################################################
# Check the following 4 variables before running the script
topdir=gcc
version=3.1.1
pkgver=1
source[0]=ftp://ftp.sunet.se/pub/gnu/gcc/releases/$topdir-$version/$topdir-$version.tar.bz2
# If there are no patches, simply comment this
patch[0]=gcc-3.1.1-fix-scandecls.patch

# Source function library
. ${BUILDPKG_SCRIPTS}/buildpkg.functions

# Common settings for gcc
. ${BUILDPKG_BASE}/gcc/build.sh.gcc.common

# Global settings

# This compiler is bootstrapped using the old gnat distributions which also
# contain gcc 2.8.1. Note that gnat 3.15p will not work.
# sparc: gnat-3.14p-sparc-sun-solaris2.5.1-bin.tar.gz
# x86: gnat-3.12p-i386-pc-solaris2.6-bin.tar.gz
# For x86 it is necessary to build gnat 3.14p from source using gnat 3.12p.
# Put gnat compiler first in the path
export PATH=$HOME/gnat314p/bin:$PATH

reg prep
prep()
{
    generic_prep
    setdir source
    # Set bugurl and vendor version
    ${__gsed} -i "/GCCBUGURL/s|URL:[^>]*|URL:$gccbugurl|" gcc/system.h
    ${__gsed} -i "s/$version/$version (release)/" gcc/version.c
    ${__gsed} -i "s/(release)/($gccpkgversion)/" gcc/version.c gcc/f/version.c
    # not gccpkgversion, because the version string will exceed max length
    ${__gsed} -i "s/(release)/(${version}-${pkgver})/" gcc/ada/gnatvsn.ads

    if [ "$vendor" = "pc" ]; then
	# Building ada with -g is not possible on x86
	${__gsed} -i '/STAGE1_CFLAGS/ s/-g//' gcc/Makefile.in
	${__gsed} -i '/FORCE_DEBUG_ADAFLAGS/ s/-g//' gcc/ada/Makefile.in
    fi
}

reg build
build()
{
    ${__mkdir} -p ${srcdir}/$objdir
    generic_build ../$objdir
    # Build gnat
    # This is hacky but the buildsystem tries to use the host gnatbind
    # where it should have used the just built one
    export PATH=$srcdir/$objdir/gcc:$PATH
    setdir ${srcdir}/${objdir}
    ${__make} -C gcc gnatlib
    ${__make} -C gcc gnattools
}

reg install
install()
{
    clean stage
    setdir ${srcdir}/${objdir}
    mkdir -p $stagedir${prefix}
    mkdir -p $stagedir${lprefix}
    ${__make} -e prefix=$stagedir${lprefix} gxx_include_dir=$stagedir$lprefix/include/c++/$version glibcppinstalldir=$stagedir$lprefix/include/c++/$version bindir=$stagedir${prefix}/bin  mandir=$stagedir${prefix}/man infodir=$stagedir${prefix}/info install
    custom_install=1
    generic_install
    ${__find} ${stagedir} -name '*.la' -print | ${__xargs} ${__rm} -f

    # Rearrange libraries
    redo_libs

    # Remove obsolete gccbug script
    ${__rm} -f $stagedir$prefix/bin/gccbug

    # Turn all the hardlinks in bin into symlinks
    redo_bin

    # Place share/docs in the regular location
    prefix=$topinstalldir
    doc COPYING* BUGS FAQ MAINTAINERS gcc/NEWS
}

reg check
check()
{
    setdir source
    setdir ../$objdir
    ${__make} -k check
}

reg pack
pack()
{
    iprefix=${topdir}${abbrev_majorminor}
    generic_pack
}

reg distclean
distclean()
{
    META_CLEAN="$META_CLEAN compver.*"
    clean distclean
    ${__rm} -rf $srcdir/$objdir
}

###################################################
# No need to look below here
###################################################
build_sh $*
