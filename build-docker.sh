#!/bin/sh
# Builds Mongo and copies the resulting distributable archives to the host machine.
# Usable tarballs should show up under `./build-docker/`.
set -e
set -x

cd "$(readlink -f "$(dirname "$0")")"

# If no tag is specified, generate our own
if [ x"${TAG}" == x"" ]; then
	TAG=mongo-build:"$(TZ=UTC date "+%Y-%m-%dZ%H.%M.%S")"
fi

# Build image if not yet extant
if [ x"$(docker image ls -q "${TAG}")" == x"" ]; then
	docker build . --tag "${TAG}"
fi

# Create an output directory on the host machine for copying the tarballs into
mkdir -p ./build-docker

# Copy the tarballs while converting from .gz to .xz
# Also build the tarballs first if they don't exist
docker run -v "$(pwd)"/build-docker:/opt/mongo-dist:z --rm "${TAG}" sh -c '
	ls mongodb-*.tgz >/dev/null 2>/dev/null || scons --cc=gcc-4.8 --cxx=g++-4.8 --prefix=/usr/local/ --distmod=spat-1-gcc4.8-v8 dist
	for f in *.tgz; do
		gunzip -c "$f" | xz -z9 > /opt/mongo-dist/"$(basename "${f}" .tgz)".tar.xz
	done
'
