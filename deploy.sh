#!/bin/bash
set -e

wait_for_port() {
  local host=$1
  local port=$2
  echo "Waiting for ${host}:${port} to be ready..."
  while ! (echo > /dev/tcp/${host}/${port}) 2>/dev/null; do
    echo "  ${host}:${port} not ready, waiting..."
    sleep 1
  done
  echo "${host}:${port} is ready!"
}

### 1. Start Web Server ###
echo "Starting Web Server..."
(cd web-server && docker-compose up --build -d)

echo "Waiting for Web Server on port 3000..."
wait_for_port "localhost" "3000"

echo "Waiting for Web DB on port 5432..."
wait_for_port "localhost" "5432"
echo "Running Web DB migrations..."

docker exec web-server-db sh -c '
  echo "🚀 Running migrations from /migrations/*.up.sql"
  for f in /migrations/*.up.sql; do
    if [ -f "$f" ]; then
      echo "🔹 Running migration: $f"
      psql -U postgres -d web_server -f "$f"
      if [ $? -ne 0 ]; then
        echo "❌ Error running migration: $f"
        exit 1
      fi
    fi
  done
  echo "✅ All migrations executed successfully."
'
if [ $? -ne 0 ]; then
  echo "Error running migrations on Web DB"
  exit 1
fi
echo "Web DB migrations completed successfully."

### 2. Start Elasticsearch ###
echo "Starting Elasticsearch..."
(cd elasticsearch && docker-compose up --build -d)
echo "Waiting for Elasticsearch on port 9200..."
wait_for_port "localhost" "9200"
echo "Elasticsearch is ready!"

### 3. Start logstash ###
echo "Starting Logstash..."
(cd logstash && docker-compose up --build -d)
echo "Waiting for Logstash on port 5044..."
wait_for_port "localhost" "5044"
echo "Logstash is ready!"

### 4. Start Kibana ###
echo "Starting Kibana..."
(cd kibana && docker-compose up --build -d)
echo "Waiting for Kibana on port 5601..."
wait_for_port "localhost" "5601"
echo "Kibana is ready!"

### 5. Import Kibana Dashboard ###
echo "Importing Kibana dashboard..."
chmod +x kibana/import-dashboard.sh
./kibana/import-dashboard.sh

### FINAL ###
echo "✅ All services have been deployed and are up!"
echo ""
echo "Access Points:"
echo "- Web Server:        http://localhost:3000"
echo "- Web DB:            http://localhost:5432"
echo "- Logstash:          http://localhost:5044"
echo "- Elasticsearch:     http://localhost:9200"
echo "- Kibana:            http://localhost:5601"

