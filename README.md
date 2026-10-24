# NetOps Manager V2

Cloudflare Workers + D1 network operations manager with a LAN NetOps Agent.

## Cloudflare
1. Create a D1 database named `netops-db` and put its ID into `wrangler.toml`.
2. Set Worker secrets/vars: `AUTH_SECRET` (random long secret) and `SETUP_KEY` (one-time admin bootstrap key).
3. GitHub Actions needs repository secrets `CLOUDFLARE_API_TOKEN` and `CLOUDFLARE_ACCOUNT_ID`.
4. Push to `main` to deploy.
5. After the first deployment, POST to `/api/setup` with `{key, username, password}` to create the first admin.

## Agent
Run `cd agent && npm install`, copy `.env.example` to `.env`, set `AGENT_BASE_URL` and `AGENT_TOKEN`, then `npm start` on a host that can reach the managed devices.

> Demo note: device credential encryption and full configuration backup/restore should be added before production use. Prefer Cloudflare Access/Zero Trust for enterprise authentication.
