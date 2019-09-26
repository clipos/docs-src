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

main() {
    readonly repo_root_path="$(cosmk repo-root-path)"

    if [[ -z "${repo_root_path}" ]]; then
        echo "[!] CLIP OS toolkit environment not activated!"
        return 1
    fi

    # Build the HTML documentation
    export SPHINXPROJ="CLIPOS"
    sphinx-build -b html -j auto . _build

    # Disable Jekyll processing for GitHub Pages hosting
    touch _build/.nojekyll

    # Set CNAME for GitHub Pages hosting
    echo "docs.clip-os.org" > _build/CNAME

    # Set minimal README
    cat > _build/README.md <<EOF
# Static content for docs.clip-os.org

See <https://docs.clip-os.org>.
EOF

    # Cleanup
    rm -f _build/.buildinfo
}

main $@

# vim: set ts=4 sts=4 sw=4 et ft=sh:
