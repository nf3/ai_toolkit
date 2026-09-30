#!/usr/bin/env bash
# Replaces the "scripts" section of package.json with Playwright login/test commands.
# The login URL comes from BASE_URL at run time, falling back to a default.
#
# Usage:  ./set-login-script.sh [path/to/package.json]
# To bake in a different default:  BASE_URL=https://my.site ./set-login-script.sh
set -euo pipefail

PKG="${1:-package.json}"
DEFAULT_URL="${BASE_URL:-https://staging.example.com}"

if [[ ! -f "$PKG" ]]; then
  echo "Error: $PKG not found. Run this from your project folder." >&2
  exit 1
fi

# Session file lives in ~/.auth (private to your user)
mkdir -p "$HOME/.auth"
chmod 700 "$HOME/.auth"

cp "$PKG" "$PKG.bak"

DEFAULT_URL="$DEFAULT_URL" node -e '
const fs = require("fs");
const file = process.argv[1];
const pkg = JSON.parse(fs.readFileSync(file, "utf8"));
pkg.scripts = {
  login: "playwright codegen --save-storage=\"$HOME/.auth/user.json\" \"${BASE_URL:-" + process.env.DEFAULT_URL + "}/login\"",
  test: "playwright test"
};
fs.writeFileSync(file, JSON.stringify(pkg, null, 2) + "\n");
' "$PKG"

echo "Updated $PKG (backup saved as $PKG.bak)"
echo "Default login URL: $DEFAULT_URL/login  (override with BASE_URL=...)"
