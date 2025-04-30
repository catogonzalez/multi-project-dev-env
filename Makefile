.PHONY: setup network start stop logs clean

# Set up hosts file entries and network
setup: network
	@echo "Setting up local domain entries (requires sudo)..."
	@grep -q "api.dev.local" /etc/hosts || sudo sh -c 'echo "127.0.0.1 api.dev.local" >> /etc/hosts'
	@grep -q "web.dev.local" /etc/hosts || sudo sh -c 'echo "127.0.0.1 web.dev.local" >> /etc/hosts'
	@grep -q "mobile.dev.local" /etc/hosts || sudo sh -c 'echo "127.0.0.1 mobile.dev.local" >> /etc/hosts'
	@echo "Local domains configured successfully"

# Create traefik-public network if it doesn't exist
network:
	@if ! docker network ls | grep -q traefik-public; then \
		echo "Creating traefik-public network..."; \
		docker network create traefik-public; \
	else \
		echo "traefik-public network already exists"; \
	fi

# Start all services
start:
	@echo "Ensuring the traefik proxy is running..."
	@if ! docker ps | grep -q "traefik:v3.1.4"; then \
		echo "Warning: Traefik proxy is not running. Please start the dev-boxes services first with:"; \
		echo "  cd ../dev-boxes && docker-compose up -d"; \
		echo "Aborting..."; \
		exit 1; \
	fi
	@echo "Starting application services..."
	docker-compose up -d
	@echo "All services started!"
	@echo "Access your services at:"
	@echo "  - API:    http://api.dev.local or https://api.dev.local"
	@echo "  - Web:    http://web.dev.local or https://web.dev.local"
	@echo "  - Mobile: http://mobile.dev.local or https://mobile.dev.local"
	@echo "  - Traefik Dashboard: http://proxy.dev.local"
	@echo "  - Database: db.dev.local:5432"

# Stop all services
stop:
	docker-compose down

# View logs of all services
logs:
	docker-compose logs -f

# Clean everything (containers, networks, volumes)
clean:
	docker-compose down
	@echo "Environment cleaned successfully"