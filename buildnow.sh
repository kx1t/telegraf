#!/bin/bash
# shellcheck disable=SC2086,SC2162


[[ "$1" != "" ]] && BRANCH="$1" || BRANCH="$(git branch --show-current)"
[[ "$BRANCH" == "main" ]] && TAG="latest" || TAG="$BRANCH"
[[ "$ARCHS" == "" ]] && ARCHS="linux/armhf,linux/arm64,linux/amd64"

BASETARGET1=ghcr.io/kx1t

IMAGE1="$BASETARGET1/$(pwd | sed -n 's|.*/\(docker-.*\)|\1|p'):$TAG"
#IMAGE2="$BASETARGET2/$(pwd | sed -n 's|.*/docker-\(.*\)|\1|p'):$TAG"

echo "press enter to start building $IMAGE1 from $BRANCH"

read

git checkout $BRANCH

starttime="$(date +%s)"
# rebuild the container
set -x
docker buildx build -f Dockerfile --compress --push $2 --platform $ARCHS --tag "$IMAGE1" .
# [[ $? ]] && docker buildx build -f Dockerfile --compress --push $2 --platform $ARCHS --tag $IMAGE2 .
mv -f Dockerfile.tmp-backup Dockerfile
echo "Total build time: $(( $(date +%s) - starttime )) seconds"