#!/usr/bin/env bash

set -euo pipefail

{{- if and .Values.runner.enabled }}
echo '==== GENERATE GITEA ACTION TOKEN ===='

wget http://{{ .Values.gitea.admin.username }}:{{ .Values.gitea.admin.password }}@gitea:3000/api/v1/admin/runners/registration-token
token=$(cat registration-token | grep -o '"token":[^"]*"[^"]*"' | sed -E 's/".*".*"(.*)"/\1/')
echo ${token} > /token

{{- end }}