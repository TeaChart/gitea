#!/usr/bin/env bash

set -euo pipefail

echo '==== BEGIN GITEA RUNNER CONFIGURATION ===='

act_runner generate-config > $CONFIG_FILE

# set the container network
l=$(grep -n 'network:' $CONFIG_FILE | cut -d ':' -f1)
sed -i "${l}s/.*/  network: \"{{ .Values.TeaChart.ProjectName }}_gitea\"/" $CONFIG_FILE

echo '==== END GITEA RUNNER CONFIGURATION ===='