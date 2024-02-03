#!/usr/bin/env bash

set -euo pipefail

echo '==== BEGIN GITEA CONFIGURATION ===='

{ # try
  gitea migrate
} || { # catch
  echo "Gitea migrate might fail due to database connection...This init-container will try again in a few seconds"
  exit 1
}

{{- if and .Values.gitea.admin.username .Values.gitea.admin.password }}
function configure_admin_user() {
  local full_admin_list=$(gitea admin user list --admin)
  local actual_user_table=''

  # We might have distorted output due to warning logs, so we have to detect the actual user table by its headline and trim output above that line
  local regex="(.*)(ID\s+Username\s+Email\s+IsActive.*)"
  if [[ "${full_admin_list}" =~ $regex ]]; then
    actual_user_table=$(echo "${BASH_REMATCH[2]}" | tail -n+2) # tail'ing to drop the table headline
  else
    # This code block should never be reached, as long as the output table header remains the same.
    # If this code block is reached, the regex doesn't match anymore and we probably have to adjust this script.

    echo "ERROR: 'configure_admin_user' was not able to determine the current list of admin users."
    echo "       Please review the output of 'gitea admin user list --admin' shown below."
    echo "       If you think it is an issue with the Helm Chart provisioning, file an issue at https://gitea.com/gitea/helm-chart/issues."
    echo "DEBUG: Output of 'gitea admin user list --admin'"
    echo "--"
    echo "${full_admin_list}"
    echo "--"
    exit 1
  fi

  local ACCOUNT_ID=$(echo "${actual_user_table}" | grep -E "\s+${GITEA_ADMIN_USERNAME}\s+" | awk -F " " "{printf \$1}")
  if [[ -z "${ACCOUNT_ID}" ]]; then
    echo "No admin user '${GITEA_ADMIN_USERNAME}' found. Creating now..."
    gitea admin user create --admin --username "${GITEA_ADMIN_USERNAME}" --password "${GITEA_ADMIN_PASSWORD}" --email {{ .Values.gitea.admin.email | quote }} --must-change-password=false
    echo '...created.'
  else
    echo "Admin account '${GITEA_ADMIN_USERNAME}' already exist. Running update to sync password..."
    gitea admin user change-password --username "${GITEA_ADMIN_USERNAME}" --password "${GITEA_ADMIN_PASSWORD}"
    echo '...password sync done.'
  fi
}

configure_admin_user

echo '==== END GITEA CONFIGURATION ===='

{{- end }}