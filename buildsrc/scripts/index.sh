#!/bin/bash

print_usage() {
	echo "Here are the args you can use."
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
	
	docker run --rm -it -v $WORK_DIR:/workdir crops/poky --workdir=/workdir
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
