#!/bin/bash
# This is a buildpkg build.sh script
# build.sh helper functions
. ${BUILDPKG_SCRIPTS}/build.sh.functions
#
###########################################################
# Check the following 4 variables before running the script
topdir=gcc
version=3.4.6
pkgver=5
source[0]=ftp://ftp.sunet.se/pub/gnu/gcc/releases/$topdir-$version/$topdir-$version.tar.bz2
## If there are no patches, simply comment this
patch[0]=gcc-3.4.6-new-makeinfo.patch
patch[1]=gcc-3.4.6-new-gas.patch
patch[2]=gcc-3.4.6-gnat-share-make.patch

# Source function library
. ${BUILDPKG_SCRIPTS}/buildpkg.functions

# Common settings for gcc
. ${BUILDPKG_BASE}/gcc/build.sh.gcc.common

# Global settings

# This compiler is bootstrapped with gcc 3.3.6
export PATH=/usr/tgcware/gcc33/bin:$PATH

reg prep
prep()
{
    generic_prep
    setdir source
    ${__gsed} -i "s/@@GCCVERSION@@/$version/" gcc/ada/Makefile.in gcc/ada/bld.adb
    # Set bugurl and vendor version
    ${__gsed} -i "s|URL:[^>]*|URL:$gccbugurl|" gcc/version.c
    ${__gsed} -i "s/$version/$version (release)/" gcc/version.c
    ${__gsed} -i "s/(release)/($gccpkgversion)/" gcc/version.c
}

reg build
build()
{
    setup_tools
    ${__mkdir} -p ${srcdir}/$objdir
    generic_build ../$objdir
    # Build gnat
    setdir ${srcdir}/${objdir}
    ${__make} -C gcc gnatlib
    ${__make} -C gcc gnattools
}

reg install
install()
{
    clean stage
    setdir ${srcdir}/${objdir}
    ${__make} DESTDIR=$stagedir install
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
    doc COPYING* BUGS FAQ MAINTAINERS NEWS
}

reg check
check()
{
    setdir source
    setdir ../$objdir
    if [ $multilib -eq 0 ]; then
	${__make} -k check
    else
	${__make} -k RUNTESTFLAGS="--target_board='unix{,$multilib_testopt}'" check
    fi
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
