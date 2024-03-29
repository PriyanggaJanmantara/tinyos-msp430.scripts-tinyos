#!/bin/bash -u
# -*- mode: shell-script; mode: flyspell-prog; -*-
#
# Copyright (c) 2010, Tadashi G Takaoka
# All rights reserved.
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions
# are met:
#
# - Redistributions of source code must retain the above copyright
#   notice, this list of conditions and the following disclaimer.
# - Redistributions in binary form must reproduce the above copyright
#   notice, this list of conditions and the following disclaimer in
#   the documentation and/or other materials provided with the
#   distribution.
# - Neither the name of Tadashi G. Takaoka nor the names of its
#   contributors may be used to endorse or promote products derived
#   from this software without specific prior written permission.
#
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
# "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
# LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS
# FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE
# COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT,
# INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
# (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
# SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
# HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT,
# STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
# ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED
# OF THE POSSIBILITY OF SUCH DAMAGE.
#

source $(dirname $0 )/main.subr

function download() {
    if [[ $nesc == nesc-current ]]; then
        clone git $nesc_repo $nesc
    else
        local version=${nesc#nesc-}
        local url=$nesc_url/v$version.tar.gz
        fetch $url $nesc.tar.gz
    fi
    return 0
}

function prepare() {
    if [[ $nesc == nesc-current ]]; then
        copy $nesc $builddir
    else
        copy $nesc.tar.gz $builddir
    fi

    if is_osx; then
        for p in $scriptsdir/${nesc}-osx_*.patch; do
            do_patch $builddir $p -p1
        done
    fi
    for p in $scriptsdir/$nesc-fix_*.patch; do
        do_patch $builddir $p -p1
    done

    return 0
}

function build() {
    do_cd $builddir
    do_cmd ./Bootstrap
    do_cmd ./configure --prefix=$prefix --disable-nls \
        || die "configure failed"
    do_cmd make -j$(num_cpus) \
        || die "make filed"
}

function install() {
    do_cd $builddir
    do_cmd sudo make -j$(num_cpus) install
}

function cleanup() { 
    do_cmd rm -rf $builddir
}

main "$@"

# Local Variables:
# indent-tabs-mode: nil
# End:
# vim: set et ts=4 sw=4:
