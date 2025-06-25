# 🤖 AI Agent Instructions for MyApp

## Phoenix Server Setup

**IMPORTANT**: Use `./start_server.sh` instead of `mix phx.server`

The `start_server.sh` script loads environment variables from `config/.env` that are required for OAuth integration with Auth0. This includes:
- AUTH0_DOMAIN
- AUTH0_CLIENT_ID  
- AUTH0_CLIENT_SECRET
- AUTH0_REDIRECT_URI
- AUTH0_HOME_URI

Without these environment variables, the OAuth.Auth0 module will fail to initialize properly.

## Development Commands

```bash
# Start server with OAuth env vars
./start_server.sh

# Run tests
DATABASE_ADAPTER=sqlite mix test

# Code quality checks
mix credo --strict # <-- !important: don't forget the --strict

**IMPORTANT**
do NOT build test directory.  Tests are in /lib and are colocated.  /support contains support files.
do NOT alter function signatures of pub functions or callbacks without prompting the user.
do NOT alter the names of modules unless explicitly asked for.
