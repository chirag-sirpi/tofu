#!/usr/bin/env bash
# =============================================================================
# setup-webhook-secret.sh
# Configures HMAC webhook secret in Jenkins so only GitHub-signed pushes
# trigger builds. Run ONCE after fresh Jenkins deployment.
#
# Usage:
#   WEBHOOK_SECRET="your-random-secret" \
#   JENKINS_URL="http://localhost:8080" \
#   JENKINS_USER="admin" \
#   JENKINS_PASS="your-password" \
#   ./bin/setup-webhook-secret.sh
# =============================================================================
set -euo pipefail

JENKINS_URL="${JENKINS_URL:-http://localhost:8080}"
JENKINS_USER="${JENKINS_USER:-admin}"
JENKINS_PASS="${JENKINS_PASS:?Set JENKINS_PASS}"
WEBHOOK_SECRET="${WEBHOOK_SECRET:?Set WEBHOOK_SECRET — this must match GitHub webhook secret}"

echo "==> Fetching Jenkins CSRF crumb..."
CRUMB=$(curl -sf -u "${JENKINS_USER}:${JENKINS_PASS}" \
  -c /tmp/jenkins_cookies.txt \
  "${JENKINS_URL}/crumbIssuer/api/json" | python3 -c "import sys,json; d=json.load(sys.stdin); print(d['crumb'])")

echo "==> Injecting webhook secret as Jenkins credential 'github-webhook-secret'..."
curl -sf -u "${JENKINS_USER}:${JENKINS_PASS}" \
  -b /tmp/jenkins_cookies.txt \
  -H "Jenkins-Crumb: ${CRUMB}" \
  --data-urlencode "script=
import jenkins.model.*
import com.cloudbees.plugins.credentials.*
import com.cloudbees.plugins.credentials.domains.*
import org.jenkinsci.plugins.plaincredentials.impl.*
import hudson.util.Secret

def store = Jenkins.instance.getExtensionList(
  com.cloudbees.plugins.credentials.SystemCredentialsProvider
)[0].getStore()

// Remove existing if present
def existing = store.getCredentials(Domain.global()).find { it.id == 'github-webhook-secret' }
if (existing) { store.removeCredentials(Domain.global(), existing) }

// Create new StringCredentials
def cred = new StringCredentialsImpl(
  CredentialsScope.GLOBAL,
  'github-webhook-secret',
  'GitHub Webhook HMAC Secret',
  Secret.fromString('${WEBHOOK_SECRET}')
)
store.addCredentials(Domain.global(), cred)
println 'github-webhook-secret credential set.'
" \
  "${JENKINS_URL}/scriptText"

rm -f /tmp/jenkins_cookies.txt

echo ""
echo "==> Done! Next steps:"
echo "    1. In Jenkins > Manage Jenkins > Configure System > GitHub:"
echo "       - Set 'Secret text' to credential 'github-webhook-secret'"
echo "       - Enable 'Specify another hook url for GitHub configuration'"
echo "    2. In GitHub repo > Settings > Webhooks > Edit:"
echo "       - Set 'Secret' to the same value: ${WEBHOOK_SECRET}"
echo "    3. Only pushes signed by GitHub with this HMAC secret will trigger builds."
