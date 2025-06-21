.PHONY: up-all up-web-server up-logstash up-elasticsearch up-kibana down-web-server down-logstash down-elasticsearch down-kibana down-all logs

up-all:
	@echo "Deploying all services in order..."
	bash ./deploy.sh

up-web-server:
	@echo "Starting web server..."
	docker compose -f web-server/docker-compose.yml up --build -d

up-logstash:
	@echo "Starting Logstash..."
	docker compose -f logstash/docker-compose.yml up --build -d

up-elasticsearch:
	@echo "Starting Elasticsearch..."
	docker compose -f elasticsearch/docker-compose.yml up --build -d

up-kibana:
	@echo "Starting Kibana..."
	docker compose -f kibana/docker-compose.yml up --build -d

down-web-server:
	docker compose -f web-server/docker-compose.yml down -v

down-logstash:
	docker compose -f logstash/docker-compose.yml down -v

down-elasticsearch:
	docker compose -f elasticsearch/docker-compose.yml down -v

down-kibana:
	docker compose -f kibana/docker-compose.yml down -v

down-all:
	@echo "Stopping all services..."
	docker compose -f logstash/docker-compose.yml down -v
	docker compose -f elasticsearch/docker-compose.yml down -v
	docker compose -f kibana/docker-compose.yml down -v
	docker compose -f web-server/docker-compose.yml down -v

logs:
	docker compose -f web-server/docker-compose.yml logs -f
	docker compose -f logstash/docker-compose.yml logs -f
	docker compose -f elasticsearch/docker-compose.yml logs -f
	docker compose -f kibana/docker-compose.yml logs -f
	
