
echo "✅ Kibana is up. Importing dashboard..."

curl -X POST http://localhost:5601/api/saved_objects/_import?overwrite=true \
  -H "kbn-xsrf: true" \
  --form file=@dashboard/kibana-dashboard.ndjson

echo "✅ Dashboard import complete"