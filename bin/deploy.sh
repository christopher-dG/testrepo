#!/bin/bash

shopt -s extglob

TARGET="$1"
CLUSTER_SETS='platform|projects'
GLOBAL_PROJECTS='beacon-aws|projects-erpeter|projects-jasper|projects-somnus'

case "${TARGET}" in
@($CLUSTER_SETS))
    PREFIX="apps-"
    TARGET="${TARGET}-clusters"
    ;;
@($GLOBAL_PROJECTS))
    PREFIX=""
    ;;
*)
    echo "ERROR: Provide an argument. It can be either:"
    echo "A cluster set:    ${CLUSTER_SETS}"
    echo "A global project: ${GLOBAL_PROJECTS}"
    exit 1
    ;;
esac

i=0
base_tag="${PREFIX}deploy-${TARGET}-$(date -I)"
branch="$(git branch --show-current)"
if [ "${branch}" != "master" ] && [ "${branch}" != "main" ]; then
    echo "ERROR: Must be on default branch; your current branch is: ${branch}"
    exit 1
fi

while true; do
    # The default tag is [prefix-]deploy-CLUSTER_SET_NAME-clusters-YYYY-MM-DD-N.
    # e.g. apps-deploy-platform-clusters-2020-12-07-0
    # In case that tag already exists, increment N by 1
    proposed="${base_tag}-${i}"
    if ! git show "${proposed}" >/dev/null 2>&1; then
        break
    fi
    # We have a collision, increment
    echo "[exists] ${proposed}"
    i=$((i + 1))
done

echo "Proposed: ${proposed}"
echo "Running: git tag -m \"Deployed by $USER\" ${proposed} && git push origin ${proposed}"
set -x
git tag -m "Deployed by $USER" "${proposed}" && git push origin "${proposed}"
