#!/bin/bash
set -eo pipefail

source /etc/os-release

basearch=$(uname -m)

( curl "https://mirrors.fedoraproject.org/metalink?repo=fedora-${VERSION_ID}&arch=${basearch}&protocol=http";
  curl "https://mirrors.fedoraproject.org/metalink?repo=updates-released-f${VERSION_ID}&arch=${basearch}&protocol=http" ) \
	| grep 'http://.*\(releases\|updates\)/[0-9]\+/Everything' \
	| sed 's@.*>\([^<]*/\)\(releases\|updates\)/[0-9]\+/Everything.*$@\1@' \
	| sed 's/[]\/$*.^[]/\\&/g' \
	| awk '{ print "^" $0 "(.*\\.rpm)$\thttp://fedora.mirrors.squid.internal/$1"; }' \
	| sort -u
