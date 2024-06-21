#!/bin/bash
set -eo pipefail

#
# Get VERSION_ID and ID
# e.g. for Fedora 40:
#   VERSION_ID=40
#   ID=fedora
#
# The VERSION_ID doesn't matter so much, since we strip it away later
# anyway. Its only relevance is that not all mirrors mirror all
# versions.
#
source /etc/os-release

arch=$(uname -m)
versions=$VERSION_ID
platform=$ID
meta_url="https://mirrors.fedoraproject.org/metalink"
map_url="http://${platform}.mirrors.squid.internal"

while [[ $# -gt 0 ]]; do
	case $1 in
	--arch )
		shift
		arch=$1
		;;
	--metalink )
		shift
		meta_url=$1
		;;
	--platform-version )
		shift
		versions=$1
		;;
	* )
		echo >&2 'invalid argument'
		exit 1
		;;
	esac
	shift
done

# We presume Squid will only be used to cache plain HTTP downloads, not
# HTTPS/other methods. Filter mirrors accordingly.
meta_url="${meta_url}?protocol=http"

# The metalink will return the best mirrors for your given location, and
# exclude ones that are far away. Since that list isn't necessarily very
# stable, just include all global mirrors.
meta_url="${meta_url}&country=global"

db_for_version_arch () {
	local version=$1
	local arch=$2

	#
	# Fetch the metalinks for normal repo and updates, find lines containing
	# suitable URLs, trim them so that only the root remains, escape them
	# for use in storeid_file_rewrite regexes, and tack on everything else
	# required by storeid_file_rewrite.
	#
	# In July 2024 on Fedora 40 x86_64, the final output has 165 entries.
	#
	( curl -sS "${meta_url}&repo=fedora-${version}&arch=${arch}";
	  curl -sS "${meta_url}&repo=updates-released-f${version}&arch=${arch}" ) \
		| sed -nr 's|^.*>([^<]*/)\w+/\w+/Everything.*$|\1|p'              \
		| sed 's/[]\/$*.^[]/\\&/g'                                        \
		| awk "{ print \"^\" \$0 \"(.*\\\\.rpm)$\\t${map_url}/\$1\"; }"
}

IFS=','
for version in ${versions}; do
	for basearch in ${arch}; do
		db_for_version_arch "${version}" "${basearch}"
	done
done | sort -u
