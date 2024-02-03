#!/usr/bin/env bash

set -euo pipefail
set -x

echo '==== BEGIN INIT DIRECTORY CONFIGURATION ===='

mkdir -p /data/git/.ssh
chmod -R 700 /data/git/.ssh
[ ! -d /data/gitea/conf ] && mkdir -p /data/gitea/conf

chown 1000:1000 /data -R

echo '==== END INIT DIRECTORY CONFIGURATION ===='