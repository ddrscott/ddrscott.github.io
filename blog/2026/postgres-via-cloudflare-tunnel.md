---
title: "Postgres via Cloudflare Tunnel"
date: 2026-02-19
created: 2026-02-19T00:00:00Z
type: blog
status: settled
tags: [postgres, devops]
publish: [ddrscott]
source: import
description: "Expose your local Postgres to the world without opening firewall ports."
image: /images/2026/postgres-via-cloudflare-tunnel.jpg
prompt: "Import from blog post: 2026/postgres-via-cloudflare-tunnel.md"
---

# Postgres via Cloudflare Tunnel

<img class="featured" src="/images/2026/postgres-via-cloudflare-tunnel.jpg" alt="PostgreSQL elephant connected to Cloudflare cloud via secure tunnel" />

**Access your home Postgres from anywhere with Cloudflare Tunnels.**

## Start the PG Server using Docker

```bash
docker run -d --name pg16 \
  -e POSTGRES_PASSWORD=secret \
  -p 15432:5432 \
  -v pg16_data:/var/lib/postgresql/data \
  pgvector/pgvector:pg16
```

## Test Local Connection using Docker

```bash
docker run -it --rm \
  -e PGPASSWORD=secret \
  pgvector/pgvector:pg16 \
  psql -h 192.168.86.250 -U postgres -p 15432 -c 'select version()'
```

> Replace `192.168.86.250` with your machine's private IP.

## Create the Tunnel

Install `cloudflared` on the Docker host following the [official guide](https://developers.cloudflare.com/cloudflare-one/networks/connectors/cloudflare-tunnel/get-started/create-remote-tunnel/).

Configure the tunnel to point to `localhost:15432`.

## Connect from Remote

On any remote machine:

```bash
cloudflared access tcp --hostname pg16.dataturd.com --url localhost:15432
```

Then connect your client to `localhost:15432` as if Postgres were local:

```bash
# With Docker
docker run -it --rm \
  -e PGPASSWORD=secret \
  --network host \
  pgvector/pgvector:pg16 \
  psql -h localhost -U postgres -p 15432 -c 'select version()'

# Or with local psql
PGPASSWORD=secret psql -h localhost -U postgres -p 15432 -c 'select version()'
```
