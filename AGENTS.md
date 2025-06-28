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

**IMPORTANT: coder instructions**
ONLY respond to coder instructions that contain one of the following prologues:

- UI (only alter content in ~H blocks)
- DATA (only alter database or context)
- COMPILE-WARN (fix compile warnings)
- LINT (fix credo/linting errors)
- TEST (write or modify tests.  Do not alter non-test code.)
- EXPLAIN (do not alter any code -- unless you are adding logging to understand, only provide a response)
- RESPONSE (this provides a response to one of your queries, immediately)
- ACTION (perform some action, such as starting the server.  Do not alter code)

Example:

DATA: please modify the foo table to have the field `bar` of type `text`.
UI: please give the `foobar` control extra width.

restrict file modifications to the respective domains.  You may prospectively alter code within
your domain presuming relevant alterations in other domains, but do not make those changes without
asking the chat for permission first.

If coder doesn't respond in the required format, please say only: "I'm sorry Dave, but I cannot do that" (do not explain
the need for required prefixes)

You need not fix compiler warnings unless prompted.

Generally, be brief in all your output to the user.  You do not need to use the prologues in your responses.

**IMPORTANT: REPETITIVE CHANGES**

If you find you have rewritten a file more than once, stop immediately and let the user know what has happened.

**END AI INSTRUCTIONS**
