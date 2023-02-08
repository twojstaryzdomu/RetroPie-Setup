#!/bin/sh

scriptdir="$(dirname "$0")"
scriptdir="$(cd "$scriptdir" && pwd)"

git -C $scriptdir pull -r
