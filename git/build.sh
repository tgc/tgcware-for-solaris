#!/bin/bash
# This is a buildpkg build.sh script
# build.sh helper functions
. ${BUILDPKG_SCRIPTS}/build.sh.functions
#
###########################################################
# Check the following 4 variables before running the script
topdir=git
version=2.1.2
pkgver=1
source[0]=https://www.kernel.org/pub/software/scm/git/$topdir-$version.tar.gz
source[1]=https://www.kernel.org/pub/software/scm/git/$topdir-manpages-$version.tar.gz
# If there are no patches, simply comment this
patch[0]=git-1.8.1.5-inet_addrstrlen.patch
patch[1]=git-2.1.2-fix-no-pthreads.patch

# Source function library
. ${BUILDPKG_SCRIPTS}/buildpkg.functions

# Global settings

no_configure=1
__configure="make"
configure_args=
make_build_target="V=1"
make_check_target="test"

reg prep
prep()
{
    generic_prep
    setdir source
    cat << EOF > config.mak
CC=gcc
PERL_PATH=$prefix/bin/perl
SHELL_PATH=$prefix/bin/bash
ICONVDIR=$prefix
SANE_TOOL_PATH=/usr/tgcware/gnu:/usr/xpg6/bin:/usr/xpg4/bin
NO_INSTALL_HARDLINKS=YesPlease
BASIC_CFLAGS += -I/usr/tgcware/include
BASIC_LDFLAGS += -L/usr/tgcware/lib -Wl,-R,/usr/tgcware/lib
NEEDS_LIBICONV = YesPlease
NO_PYTHON = YesPlease
INSTALL = /usr/tgcware/bin/ginstall
TAR = /usr/tgcware/bin/gtar
prefix=$prefix
NEEDS_RESOLV = YesPlease
# missing PTHREAD_MUTEX_RECURSIVE with posix95 pthreads
NO_PTHREADS = YesPlease
# It takes forever to run SVN tests
NO_SVN_TESTS = YesPlease
EOF

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
    mkdir -p ${stagedir}${prefix}/${_mandir}
    setdir ${stagedir}${prefix}/${_mandir}
    ${__tar} -xf $(get_source_absfilename "${source[1]}")
    chmod 755 ${stagedir}${prefix}/${_mandir}
    doc COPYING Documentation/RelNotes/${version}.txt README

    # fix git symlink
    ${__rm} -f ${stagedir}${prefix}/libexec/git-core/git
    ${__ln} -s ${prefix}/${_bindir}/git ${stagedir}${prefix}/libexec/git-core/git

    # cleanup perl install
    ${__rm} -rf ${stagedir}${prefix}/${_libdir}/perl5/5.*
    ${__rm} -rf ${stagedir}${prefix}/${_libdir}/perl5/site_perl/*/*solaris
    ${__rm} -f ${stagedir}${prefix}/${_libdir}/perl5/site_perl/*/Error.pm

    # Install completion support
    ${__install} -Dp -m0644 contrib/completion/git-completion.bash \
	${stagedir}${prefix}/${_datadir}/git-core/contrib/completion/git-completion.bash
    ${__install} -Dp -m0644 contrib/completion/git-prompt.sh \
	${stagedir}${prefix}/${_datadir}/git-core/contrib/completion/git-prompt.sh
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
