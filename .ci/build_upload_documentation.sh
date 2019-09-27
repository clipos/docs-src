#!/bin/bash
# SPDX-License-Identifier: LGPL-2.1-or-later
# Copyright © 2019 ANSSI. All rights reserved.

set -o errexit -o nounset -o xtrace -o pipefail

export SPHINXPROJ='CLIPOS'

# Build the HTML documentation
sphinx-build -b html -j auto . _build

# Disable Jekyll processing for GitHub Pages hosting
touch _build/.nojekyll

# Set CNAME, README & LICENSE for GitHub Pages hosting
cp .ci/CNAME .ci/README.md LICENSE.md _build

# Cleanup
rm -f _build/.buildinfo

# Clone destination repo
git clone https://github.com/clipos/docs.git

# Remove everything excepted .git
pushd docs && rm -rf ./* ./.doctrees && popd

# Copy new content
cp -r _build/* _build/.doctrees docs

# Setup Git identity
git config --global user.email 'clipos@ssi.gouv.fr'
git config --global user.name 'CLIP OS documentation bot'

# Work in docs repo from now on
cd docs

# Add and commit new content
git add --all
git commit -m "$(date --iso-8601) update"

# Setup git credential helper
git config credential.helper "/bin/bash ${CI_PROJECT_DIR}/.ci/credential-helper.sh"

# Setup GitHub remote
git remote add github https://github.com/clipos/docs.git

# Push to GitHub
git push github master:master
