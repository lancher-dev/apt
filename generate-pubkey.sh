#!/bin/bash

set -euo pipefail

EMAIL="info@lucapattocchio.dev"
NAME="lancher"
REPO_DIR="$(cd "$(dirname "$0")" && pwd)"
PUBKEYS_DIR="${REPO_DIR}/pubkeys"

mkdir -p "${PUBKEYS_DIR}"

# Generate Ed25519 key silently
gpg --quiet --batch --gen-key 2>/dev/null << EOF
Key-Type: EdDSA
Key-Curve: Ed25519
Key-Usage: sign
Name-Real: ${NAME}
Name-Email: ${EMAIL}
Expire-Date: 0
%no-passphrase
%commit
EOF

# Get the short key ID
KEYID=$(gpg --list-secret-keys \
  --keyid-format=short \
  --with-colons "${EMAIL}" 2>/dev/null \
  | awk -F: '/^sec/{print $5}' \
  | tail -1)

if [ -z "${KEYID}" ]; then
  echo "ERROR: key generation failed or key ID not found." >&2
  exit 1
fi

PUBKEY_FILE="${PUBKEYS_DIR}/pubkey_${KEYID}.asc"

# Export public key
gpg --quiet --armor --export "${EMAIL}" > "${PUBKEY_FILE}" 2>/dev/null

echo "OK — Key ID: ${KEYID}"
echo "     Public key: pubkeys/pubkey_${KEYID}.asc"
echo ""
echo "Private key:"
echo "---"
gpg --quiet --armor --export-secret-keys "${EMAIL}"
echo "---"