#!/bin/bash
# shellcheck disable=SC2086,SC2162


[[ "$1" != "" ]] && BRANCH="$1" || BRANCH="$(git branch --show-current)"
[[ "$BRANCH" == "main" ]] && TAG="latest" || TAG="$BRANCH"
DEST="${DEST:-push}"

[[ "${DEST}" == "push" ]] && PLATFORM="--platform ${ARCHS:-linux/armhf,linux/arm64,linux/amd64}" || true

BASETARGET1=ghcr.io/kx1t

IMAGE1="$BASETARGET1/$(pwd | sed -n 's|.*/\(docker-.*\)|\1|p'):$TAG"

echo "press enter to start building $IMAGE1 from $BRANCH with destination \"${DEST}\""
read

git checkout $BRANCH

starttime="$(date +%s)"
# rebuild the container
set -x
docker buildx build -f Dockerfile --compress --${DEST} $2 ${PLATFORM} --tag "$IMAGE1" .
echo "Total build time: $(( $(date +%s) - starttime )) seconds"
