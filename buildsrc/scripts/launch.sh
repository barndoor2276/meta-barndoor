#!/bin/bash

print_usage() {
	echo "Usage: launch.sh [OPTIONS]"
	echo -e "  --workdir\t\tSet the directory to run the build."
	echo -e "  --h, --help\t\tDisplay this help and exit."
}

while [[ $# -gt 0 ]]; do
	case "$1" in
		--workdir)
			WORK_DIR="$2"
			shift
			;;
		-h | --help)
			print_usage && exit 0
			;;
		*)
			echo "Invalid argument [$1]"
			print_usage && exit 1
			;;
	esac
	shift
done

download_sources() {
	local YOCTO_BRANCH="dunfell"

	mkdir -p $SOURCES_DIR

	pushd $SOURCES_DIR
	
	if [ -d poky ]; then
		pushd poky
		git checkout $YOCTO_BRANCH && git pull
		popd
	else
		git clone --branch $YOCTO_BRANCH git://git.yoctoproject.org/poky
	fi

	popd
}

launch_docker_build() {
	docker pull crops/poky

	mkdir -p $WORK_DIR

	echo "docker run \
		--rm \
		-it \
		--cpus=$(nproc --all) \
		-v "$(realpath $(dirname $(dirname $0)))":/usr/bin/bb \
		-v $WORK_DIR:/workdir \
		crops/poky \
			--workdir=/workdir \
			/usr/bin/bb/build.sh"
	
	docker run \
		--rm \
		-it \
		--cpus=$(nproc --all) \
		-v "$(realpath $(dirname $(dirname $0)))":/usr/bin/bb \
		-v $WORK_DIR:/workdir \
		crops/poky \
			--workdir=/workdir \
			/usr/bin/bb/scripts/build.sh
}

verify_settings() {
	[ -z $WORK_DIR ] && echo "Expected argument --workdir." && exit 1
	SOURCES_DIR="$WORK_DIR/sources"
}

main() {
	verify_settings || exit 1
	download_sources || exit 1
	launch_docker_build || exit 1
}

#################
main && exit 0
exit 1
#################
