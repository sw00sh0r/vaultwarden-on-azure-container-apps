IP_ADDRESS=$(curl -s "https://dns.google/resolve?name=exampledomain.duckdns.org&type=A" | jq -r '.Answer[0].data')

curl -X PATCH "https://api.cloudflare.com/client/v4/zones/EXAMPLEZONE/rulesets/EXAMPLERULSESET/rules/EXAMPLERULE" \
  -H "X-Auth-Email: example@googlemail.com" \
  -H "X-Auth-Key: 123456789hfueuejd123456789" \
  -d '{
    "action": "block",
    "description": "Block Admin Page",
    "enabled": true,
    "expression": "(http.host eq \"10381899.xyz\" and http.request.uri.path contains \"/admin\" and ip.src ne '$IP_ADDRESS')",
    "id": "EXAMPLEID",
    "last_updated": "2025-04-11T08:49:10.191053Z",
    "ref": "EXMAPLEREF",
    "version": "1"    
}'