#!/bin/bash
# This is a buildpkg build.sh script
# build.sh helper functions
. ${BUILDPKG_SCRIPTS}/build.sh.functions
#
###########################################################
# Check the following 4 variables before running the script
topdir=openssl
version=3.0.11
pkgver=1
source[0]=https://openssl.org/source/$topdir-$version.tar.gz
# If there are no patches, simply comment this
patch[0]=0001-Fix-fallback-for-missing-getaddrinfo.patch
patch[1]=0002-Include-sys-atomic.h-directly-on-Solaris.patch
patch[2]=0003-Provide-socklen_t-on-Solaris-2.6.patch
patch[3]=0005-Handle-missing-stdint.h-on-older-Solaris.patch
patch[4]=0006-Handle-missing-strtoumax.patch
patch[5]=0007-Use-target-CPU-choice-on-SPARC.patch

# Source function library
. ${BUILDPKG_SCRIPTS}/buildpkg.functions

# For cpu settings
. ${BUILDPKG_BASE}/gcc/build.sh.gcc.cpu

# Global settings
make_check_target="test"
__configure="./Configure"
configure_args=(--prefix=$prefix --openssldir=${prefix}/${_sharedir}/ssl --with-rand-seed=devrandom,egd zlib shared enable-egd)
if [ "$arch" = "sparc" ]; then
    configure_args+=(solaris-sparc${gcc_arch}-gcc)
else
    configure_args+=(386 solaris-x86-gcc)
    configure_args+=(CFLAGS="-march=${gcc_arch}")
fi
configure_args+=(LDFLAGS="-L$prefix/lib -R$prefix/lib -lposix4")
cpus_online=$(psrinfo | nawk '/on-line/ {count++} END { print count }')

reg prep
prep()
{
    generic_prep
    setdir source
    # gcc < 4.6.0 will not link -lpthread when -pthread is combined
    # with -shared (see PR target/18788)
    ${__gsed} -i '/ex_libs/ s/-pthread/-lpthread/' Configurations/10-main.conf
}

reg build
build()
{
    setdir source

    echo $__configure "${configure_args[@]}"
    $__configure "${configure_args[@]}"

    ${__make} -j${cpus_online} depend
    ${__make} -j${cpus_online}
}

reg check
check()
{
    generic_check
}

reg install
install()
{
    clean stage
    setdir source
    ${__make} DESTDIR=$stagedir install
    # Make .sos writable
    chmod 755 ${stagedir}${prefix}/${_libdir}/*.so.*
    chmod 755 ${stagedir}${prefix}/${_libdir}/engines-3/*.so
    # Nuke static libraries - they just take up space
    ${__rm} -f ${stagedir}${prefix}/${_libdir}/*.a

    doc README* CHANGES.md LICENSE.txt NEWS.md

    custom_install=1
    generic_install INSTALL_PREFIX

    # Compatible with previous releases
    compat openssl 3.0.2 1 1
    compat openssl 3.0.3 1 1
    compat openssl 3.0.5 1 1
    compat openssl 3.0.7 1 1
    compat openssl 3.0.9 1 1
    compat openssl 3.0.10 1 1
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
