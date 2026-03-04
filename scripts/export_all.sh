#!/usr/bin/env bash
set -euo pipefail
source /opt/n8n-ops/.env
mkdir -p /opt/n8n-ops/workflows

# 이전 export 잔여 파일(이름 변경/삭제된 워크플로우) 정리
find /opt/n8n-ops/workflows -maxdepth 1 -type f -name '*.json' -delete

curl -sS -H "X-N8N-API-KEY: $N8N_API_KEY" "$N8N_BASE_URL/api/v1/workflows" \
| jq -r '.data[] | [.id, .name] | @tsv' \
| while IFS=$'\t' read -r id name; do
  safe=$(echo "$name" | sed 's#[ /]#_#g')
  out="/opt/n8n-ops/workflows/${safe}.json"

  curl -sS -H "X-N8N-API-KEY: $N8N_API_KEY" "$N8N_BASE_URL/api/v1/workflows/$id" > "$out"

  # 민감정보 마스킹 (key/token/password/secret/apiKey 등)
  python3 - "$out" << 'PY'
import json,sys
p=sys.argv[1]
obj=json.load(open(p))

SENSITIVE={"key","token","apikey","api_key","password","secret","authorization","access_token","refresh_token"}

def scrub_map(m):
    changed=False
    if isinstance(m,dict):
        # n8n query/header parameter 형태: {"name":"token","value":"..."}
        n=str(m.get("name","")).lower()
        if n in SENSITIVE and isinstance(m.get("value"),str):
            v=m.get("value","")
            if v and not v.startswith("={{"):
                m["value"]=f"__REDACTED_{n.upper()}__"
                changed=True

        for k,v in list(m.items()):
            lk=str(k).lower()
            if lk in SENSITIVE and isinstance(v,str) and v and not v.startswith("={{"):
                m[k]=f"__REDACTED_{lk.upper()}__"
                changed=True
            else:
                changed = scrub_map(v) or changed
    elif isinstance(m,list):
        for it in m:
            changed = scrub_map(it) or changed
    return changed

scrub_map(obj)
json.dump(obj, open(p,'w'), ensure_ascii=False, separators=(',',':'))
PY

  echo "exported: $name"
done
