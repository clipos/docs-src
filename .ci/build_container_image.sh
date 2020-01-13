#!/bin/bash
# SPDX-License-Identifier: LGPL-2.1-or-later
# Copyright © 2019 ANSSI. All rights reserved.

set -o errexit -o nounset -o xtrace -o pipefail

# Create Docker compatible images
export BUILDAH_FORMAT=docker

TIMESTAMP="$(date '+%Y%m%d%H%M%S')"
LOCAL_NAME="doc:${TIMESTAMP}"

buildah build-using-dockerfile --isolation=chroot --file .ci/Dockerfile --tag ${LOCAL_NAME} .ci

buildah login -u ${CI_REGISTRY_USER} -p ${CI_REGISTRY_PASSWORD} ${CI_REGISTRY}

buildah push ${LOCAL_NAME} ${CI_REGISTRY_IMAGE}:${TIMESTAMP}
buildah push ${LOCAL_NAME} ${CI_REGISTRY_IMAGE}:latest

buildah rmi ${LOCAL_NAME}
