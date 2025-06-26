# 🤖 AI Agent Instructions for MyApp

## Phoenix Server Setup

**IMPORTANT**: Use `./start_server.sh` instead of `mix phx.server`

## Development Commands

```bash
# Start server with OAuth env vars
./start_server.sh

# Run tests
mix test

# Code quality checks
mix credo --strict # <-- !important: don't forget the --strict
```

Architecture notes:
This repo deviates from standard phoenix web architecture.  When modifying
web components, please examine related content.  For example, for any live view,
look at how other live views are done first.  For the router, please look at how
the other routes are organized and stay consistent.

Do not attempt to create Phoenix macros, and prefer using `alias` instead of `import`.

When in doubt, consult ARCHITECTURE.md

Migrations:
Since this repo is currently in exploration mode, you do not need to create migrations
designed to safely migrate data, though migrations should still generally focus on one
topic.

Logins: 
You don't have to log in using the standard oauth flow.  In development, you have access to
`/dev/login_as/<uuid>` which will get you in as a particular user.  You can also run
`/dev/logout` to log out.

**IMPORTANT** Soft-locked modules
Do not alter the following modules without asking for user permission first:
`Web`
`Oauth`

**IMPORTANT** Soft-locked files
Do not alter the following directories without asking for user permission first:
`/config`
`/web/error`

**IMPORTANT**
do not build test directory.  Tests are in `/lib` and colocated.  `/support` contains support files.

** END AI INSTRUCTIONS **