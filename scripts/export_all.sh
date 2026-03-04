#!/usr/bin/env bash
set -euo pipefail
source /opt/n8n-ops/.env
mkdir -p /opt/n8n-ops/workflows

curl -sS -H "X-N8N-API-KEY: $N8N_API_KEY" "$N8N_BASE_URL/api/v1/workflows" \
| jq -r '.data[] | [.id, .name] | @tsv' \
| while IFS=$'\t' read -r id name; do
safe=$(echo "$name" | sed 's#[ /]#_#g')
curl -sS -H "X-N8N-API-KEY: $N8N_API_KEY" "$N8N_BASE_URL/api/v1/workflows/$id" \
> "/opt/n8n-ops/workflows/${safe}.json"
echo "exported: $name"
done
