#!/usr/bin/env bash
# SPDX-License-Identifier: LGPL-2.1-or-later
# Copyright © 2017 ANSSI. All rights reserved.

# Safety settings: do not remove!
set -o errexit -o nounset -o pipefail

# Do not run as root
if [[ "${EUID}" == 0 ]]; then
    echo "[*] Do not run as root!"
    exit 1
fi

# TODO:
# * Offline mode: skip image pull, use alternative registry, etc.

main() {
    # Registry
    readonly registry="registry.gitlab.com"
    # Image name
    readonly image_name="clipos/docs-src"
    # Full container image name including registry
    local image="${registry}/${image_name}"

    # Variable to store the return code for potentially failing commands
    local rc=0

    local runtime=""
    # Is sphinx installed on the system and are we told to use it?
    if [[ ( -n "$(command -v sphinx-build)" ) && ( -n "${CLIPOS_USE_HOST_TOOLS+x}" ) ]]; then
        runtime="host"
    # Is podman or docker available?
    elif [[ -n "$(command -v podman)" ]]; then
        runtime="podman"
    elif [[ -n "$(command -v docker)" ]]; then
        runtime="docker"
    else
        >&2 echo "Could not find either podman or docker in PATH."
        >&2 echo "Set CLIPOS_USE_HOST_TOOLS="true" if you want to use system installed \"sphinx-build\"."
        exit 1
    fi

    local cmd="sphinx-build -b html -j auto . _build"

    local user=""
    if [[ ${runtime} == "podman" || ${runtime} == "docker" ]]; then
        # Only try to run in non-privilege mode if using podman and /etc/sub{u,g}uid is configured
        if [[ ( -z "$(grep "$(id --user --name):" /etc/subuid)" ) || ( ${runtime} == "docker" ) ]]; then
            echo "[*] Running using privileged ${runtime} container"
            runtime="sudo ${runtime}"
            user="--user $(id --user):"
        else
            echo "[*] Running using unprivileged ${runtime} container"
            user=""
        fi
        # Look for image
        ${runtime} inspect "${image}" > /dev/null && rc=${?} || rc=${?}
        if [[ ${rc} -ne 0 ]]; then
            # Pull image from GitLab registry
            ${runtime} pull "${image}" && rc=${?} || rc=${?}
            if [[ ${rc} -ne '0' ]]; then
                # Build image
                pushd .ci > /dev/null
                ${runtime} build -f Dockerfile -t "${image_name}" .
                popd > /dev/null
                image="${image_name}"
            fi
        fi
        opts="--security-opt label=disable --rm -ti -e SPHINXPROJ='CLIPOS' ${user} --volume .:/mnt:rw --workdir /mnt"
        cmd="${runtime} run ${opts} ${image} ${cmd}"
    else
        export SPHINXPROJ='CLIPOS'
        echo "[*] Running using system installed \"sphinx-build\""
    fi

    # Build the HTML documentation
    ${cmd}
}

main ${@}

# vim: set ts=4 sts=4 sw=4 et ft=sh:
