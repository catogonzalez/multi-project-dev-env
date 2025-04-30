# Multi-Project Development Environment

This setup allows you to run all your projects (API, Web, and Mobile) with a single command using Docker Compose and Traefik. It works alongside the `dev-boxes` environment, reusing the Traefik proxy and database services.

## Directory Structure

```
your-workspace/
├── dev-boxes/                   # The existing Traefik & DB setup
│   └── docker-compose.yml
├── multi-project/               # This repo
│   ├── docker-compose.yml
│   ├── Makefile
│   └── README.md
├── api-project/                 # Your API repo
├── web-project/                 # Your Web app repo
└── mobile-project/              # Your Mobile app repo
```

## Prerequisites

- Docker and Docker Compose
- Make (optional, but recommended)
- Admin/sudo rights (to modify /etc/hosts)
- Your `dev-boxes` environment with Traefik and PostgreSQL already set up

## Setup Instructions

1. **Clone this repository** into a directory that's a sibling to your project repositories and your `dev-boxes` directory:

   ```bash
   mkdir -p your-workspace
   cd your-workspace
   git clone <this-repo-url> multi-project
   # Your other projects should be at the same level
   ```

2. **Configure local domain resolution and create the network**:

   ```bash
   cd multi-project
   make setup
   ```

   This:
   - Creates the `traefik-public` Docker network if it doesn't exist
   - Adds entries to your `/etc/hosts` file to resolve the custom domains

3. **Adjust the docker-compose.yml** to match your project structure:
   - Update the `context` paths to point to your project directories
   - Adjust the port numbers in the Traefik labels to match your services

## Usage

### Start the Environment

First, make sure your `dev-boxes` environment is running:

```bash
cd ../dev-boxes
docker-compose up -d
```

Then start your multi-project services:

```bash
cd ../multi-project
make start
```

This will:
- Check that Traefik is running
- Build and start all your project services
- Connect them to your existing Traefik proxy
- Connect the API to your existing PostgreSQL database

### Access Your Services

- API: http://api.dev.local or https://api.dev.local
- Web App: http://web.dev.local or https://web.dev.local
- Mobile App: http://mobile.dev.local or https://mobile.dev.local
- Traefik Dashboard: http://proxy.dev.local
- Database: db.dev.local:5432

### Other Commands

```bash
# View logs from all services
make logs

# Stop all services
make stop

# Clean up everything (containers)
make clean
```

## Customization

### Adding More Services

To add another service, extend the `docker-compose.yml` file:

```yaml
new-service:
  build:
    context: ../new-service-project
  volumes:
    - ../new-service-project:/app
  labels:
    - "traefik.enable=true"
    - "traefik.http.routers.new-service.rule=Host(`new-service.dev.local`)"
    - "traefik.http.routers.new-service.entrypoints=web"
    - "traefik.http.services.new-service.loadbalancer.server.port=YOUR_PORT"
    # HTTPS support
    - "traefik.http.routers.new-service-secure.rule=Host(`new-service.dev.local`)"
    - "traefik.http.routers.new-service-secure.entrypoints=websecure"
    - "traefik.http.routers.new-service-secure.tls=true"
  networks:
    - traefik-public
```

Don't forget to add the new domain to the `/etc/hosts` file or update the `setup` command in the Makefile.

### Database Access

Your API service is configured to connect to the PostgreSQL database from your `dev-boxes` environment. The connection string is set to:

```
postgres://postgres:postgres@db.dev.local:5432/postgres
```

Adjust the environment variables in the `docker-compose.yml` file if your database configuration is different.