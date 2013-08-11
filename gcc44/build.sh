#!/bin/bash
# This is a buildpkg build.sh script
# build.sh helper functions
. ${BUILDPKG_SCRIPTS}/build.sh.functions
#
###########################################################
# Check the following 4 variables before running the script
snapshot=
topdir=gcc
version=4.4.6
pkgver=1
source[0]=ftp://ftp.sunet.se/pub/gnu/gcc/releases/$topdir-$version/$topdir-$version.tar.bz2
#source[0]=gcc-4.3-$snapshot.tar.bz2
## If there are no patches, simply comment this
#patch[0]=

# Source function library
. ${BUILDPKG_SCRIPTS}/buildpkg.functions

# Global settings
# Define abbreviated version number (for pkgdef)
abbrev_ver=$(echo $version | ${__tr} -d '.')
# Just major.minor, no subminors
majorminor=$(echo $version | cut -d. -f1-2)

lprefix=$prefix
[ -n "$snapshot" ] && topsrcdir=gcc-$version-$snapshot
prefix=/usr/tgcware/${topdir}${majorminor}
__configure="../$topsrcdir/configure"
make_build_target=bootstrap


configure_args=(--prefix=$prefix --with-local-prefix=$prefix --with-gmp=$lprefix --with-mpfr=$lprefix --disable-nls --enable-shared)
langs="--enable-languages=c,ada,c++,fortran,objc,obj-c++"
linker="--without-gnu-ld --with-ld=/usr/ccs/bin/ld"
assembler="--without-gnu-as --with-as=/usr/ccs/bin/as"
objdir=all_native
# platform/arch specific options
[ "$_os" = "sunos57" ] && { langs="$langs,java --with-java-awt=xlib"; sol27=1; }
[ "$arch" = "sparc" ] && { vendor="sun"; sparc=1; } || { vendor="pc"; intel=1; }
[ "$arch" = "sparc" -a -n "$(isalist | grep sparcv9)" ] && { sparcv9=1; m64run=1; } || m64run=0
[ "$arch" = "sparc" ] && configure_args+=(--with-cpu=v7)

configure_args+=($linker $assembler $langs $platform_configure_args)

LDFLAGS="-Wl,-R,$prefix/lib -Wl,-R,$lprefix/lib"

export CONFIG_SHELL=/bin/ksh

datestamp()
{
    date +%Y%m%d%H%M
}

reg prep
prep()
{
    datestamp
    generic_prep
    datestamp
}

reg build
build()
{
    datestamp
    setdir source
    ${__mkdir} -p ../$objdir
    echo "$__configure $configure_args"
    setdir ../$objdir
    ${__configure} $configure_args    
    ${__make} -j4 LDFLAGS="$LDFLAGS" BOOT_LDFLAGS="$LDFLAGS" $make_build_target
   #  ${__make} LDFLAGS="$LDFLAGS" BOOT_LDFLAGS="$LDFLAGS"
    #generic_build ../$objdir
    datestamp
}

reg install
install()
{
    datestamp
    clean stage
    setdir ${srcdir}/${objdir}
    ${__make} DESTDIR=$stagedir install
    custom_install=1
    generic_install
    ${__find} ${stagedir} -name '*.la' -print | ${__xargs} ${__rm} -f

    # Prepare for split lib packages
    ${__mkdir} -p ${stagedir}${lprefix}/${_libdir}
    setdir ${stagedir}${prefix}/${_libdir}
    ${__tar} -cf - libgcc_s.so.1 libstdc++.so.6* libgfortran.so.3* libobjc.so.2* libgomp.so.1* |
	(cd ${stagedir}${lprefix}/${_libdir}; ${__tar} -xvBpf -)
    if [ $m64run -eq 1 ]; then # Also install v9 libraries
	    ${__mkdir} -p ${stagedir}${lprefix}/${_libdir}/sparcv9
	    setdir ${stagedir}${prefix}/${_libdir}/sparcv9
	    ${__tar} -cf - libgcc_s.so.1 libstdc++.so.6* libgfortran.so.3* libobjc.so.2* libgomp.so.1* |
		(cd ${stagedir}${lprefix}/${_libdir}/sparcv9; ${__tar} -xvBpf -)
    fi

    # Grab gnat libraries from adalib
    ${__cp} -p ${stagedir}${prefix}/${_libdir}/gcc/${arch}-${vendor}-solaris*/${version}/adalib/libgnarl-$majorminor.so ${stagedir}${lprefix}/${_libdir}
    ${__cp} -p ${stagedir}${prefix}/${_libdir}/gcc/${arch}-${vendor}-solaris*/${version}/adalib/libgnat-$majorminor.so ${stagedir}${lprefix}/${_libdir}

    # Turn all the hardlinks in bin into symlinks
    setdir ${stagedir}${prefix}/${_bindir}
    for i in c++ ${arch}-${vendor}-solaris*-c++ ${arch}-${vendor}-solaris*-g++
    do
	${__rm} -f $i
        ${__ln} -sf g++ $i
    done
    for i in ${arch}-${vendor}-solaris*-gcc ${arch}-${vendor}-solaris*-gcc-$version
    do
	${__rm} -f $i
        ${__ln} -sf gcc $i
    done
    for i in ${arch}-${vendor}-solaris*-gfortran
    do
	${__rm} -f $i
        ${__ln} -sf gfortran $i
    done
    for i in ${arch}-${vendor}-solaris*-gcj
    do
	${__rm} -f $i
        ${__ln} -sf gcj $i
    done

    # Place share/docs in the regular location
    prefix=$topinstalldir
    doc COPYING* MAINTAINERS NEWS

    # Setup compat files
    for pkg in libgcc_s1 libstdc++6
    do
	${__rm} -f $metadir/compver.$pkg
	compat $pkg 3.4.6 1 5
	compat $pkg 4.0.4 1 2
	compat $pkg 4.1.2 1 2
	compat $pkg 4.2.3 1 2
	compat $pkg 4.2.4 1 2
	compat $pkg 4.3.1 1 2
	compat $pkg 4.3.2 1 2
	compat $pkg 4.3.3 1 2
	compat $pkg 4.3.4 1 2
	compat $pkg 4.3.5 1 2
    done
    compat libobjc2 4.2.3 1 2
    compat libobjc2 4.2.4 1 2
    compat libobjc2 4.3.1 1 2
    compat libobjc2 4.3.2 1 2
    compat libobjc2 4.3.3 1 2
    compat libobjc2 4.3.4 1 2
    compat libobjc2 4.3.5 1 2
    compat libgomp1 4.2.3 1 2
    compat libgomp1 4.2.4 1 2
    compat libgomp1 4.3.1 1 2
    compat libgomp1 4.3.2 1 2
    compat libgomp1 4.3.3 1 2
    compat libgomp1 4.3.4 1 2
    compat libgomp1 4.3.5 1 2
    compat libgfortran3 4.3.1 1 2
    compat libgfortran3 4.3.2 1 2
    compat libgfortran3 4.3.3 1 2
    compat libgfortran3 4.3.4 1 2
    compat libgfortran3 4.3.5 1 2
    datestamp
}

reg check
check()
{
    datestamp
    setdir source
    setdir ../$objdir
    # If we can run v9 binaries then we also run the testsuite with -m64
    if [ $m64run -eq 0 ]; then
	${__make} -k check
    else
	echo "Running the testsuite also with -m64"
	${__make} -k RUNTESTFLAGS="--target_board='unix{,-m64}'" check
    fi
    datestamp
}

reg pack
pack()
{
    datestamp
    iprefix=${topdir}${majorminor}
    generic_pack
    datestamp
}

reg distclean
distclean()
{
    META_CLEAN="$META_CLEAN compver.*"
    clean distclean
    setdir $srcdir
    ${__rm} -rf $objdir
}

###################################################
# No need to look below here
###################################################
build_sh $*
