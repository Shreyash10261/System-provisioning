#!/usr/bin/env bash
set -euo pipefail

# Run after `terraform apply`. It checks that every public web server responds
# with HTTP 200. The private database is intentionally not tested from here:
# use the commands in README.md from a web VM for the tier-to-tier test.

web_count=0
while IFS= read -r ip; do
  [[ -z "$ip" ]] && continue
  # curl returns a non-zero status for connection failures; keep the HTTP code
  # so this script can report the failing server instead of exiting silently.
  status=$(curl --connect-timeout 10 --max-time 20 --silent --output /dev/null --write-out '%{http_code}' "http://${ip}" || true)
  if [[ "$status" != "200" ]]; then
    echo "FAIL: ${ip} returned HTTP ${status}" >&2
    exit 1
  fi
  echo "PASS: ${ip} returned HTTP 200"
  web_count=$((web_count + 1))
done < <(terraform output -json web_public_ips | tr -d '[]"' | tr ',' '\n')

if [[ "$web_count" -eq 0 ]]; then
  echo "FAIL: Terraform did not return any web public IP addresses." >&2
  exit 1
fi
