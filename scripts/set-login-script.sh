#!/usr/bin/env bash
# Replaces the "scripts" section of package.json with Playwright login/test commands.
# The login URL comes from BASE_URL at run time, falling back to a default.
#
# Usage:  ./set-login-script.sh            (run from the project folder)
# To bake in a different default:  BASE_URL=https://my.site ./set-login-script.sh
set -euo pipefail

DEFAULT_URL="${BASE_URL:-https://staging.example.com}"

# Load nvm if Node was installed through it (scripts don't read ~/.zshrc or ~/.bashrc)
export NVM_DIR="${NVM_DIR:-$HOME/.nvm}"
[[ -s "$NVM_DIR/nvm.sh" ]] && source "$NVM_DIR/nvm.sh"

if ! command -v npm >/dev/null 2>&1; then
  echo "Error: node/npm not found. Install Node (https://nodejs.org) or check your PATH." >&2
  exit 1
fi

if [[ ! -f package.json ]]; then
  echo "Error: package.json not found. Run this from your project folder." >&2
  exit 1
fi

# Session file lives in ~/.auth (private to your user)
mkdir -p "$HOME/.auth"
chmod 700 "$HOME/.auth"

cp package.json package.json.bak

npm pkg delete scripts
npm pkg set \
  "scripts.login=playwright codegen --save-storage=\"\$HOME/.auth/user.json\" \"\${BASE_URL:-$DEFAULT_URL}/login\"" \
  "scripts.test=playwright test"

echo "Updated package.json (backup saved as package.json.bak)"
echo "Default login URL: $DEFAULT_URL/login  (override with BASE_URL=...)"
