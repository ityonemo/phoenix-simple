# MyApp Architecture Documentation

MyApp uses a **domain-driven architecture** that prioritizes business logic organization over technical file type groupings. This approach makes the codebase more maintainable and easier to navigate as the application grows.

## Directory Structure

```
lib/
├── my_app/                    # Application context (business logic)
│   ├── application.ex         # OTP application supervisor tree
│   ├── telemetry.ex          # Application metrics and monitoring
│   └── users.ex              # User management context
├── data/                     # Data layer (schemas and repo)
│   ├── repo.ex               # Ecto repository
│   └── user.ex               # User schema with role enum
├── oauth/                    # OAuth integration layer
│   ├── auth0.ex              # Auth0 OAuth provider
│   ├── cache.ex              # OAuth token/user info caching
│   ├── auth0_test.exs        # Auth0 provider tests
│   └── cache_test.exs        # Cache provider tests
├── web/                      # Web layer (controllers, live views, etc.)
│   ├── endpoint.ex           # Phoenix endpoint configuration
│   ├── router.ex             # Application routing
│   ├── layouts.ex            # Layout components and flash handling
│   ├── auth/                 # Authentication controllers
│   │   ├── controller.ex     # OAuth flow handling
│   │   └── controller_test.exs
│   ├── admin/                # Admin-specific modules
│   │   ├── dashboard_live.ex
│   │   └── dashboard_live_test.exs
│   ├── user/                 # User-specific modules
│   │   ├── dashboard_live.ex
│   │   └── dashboard_live_test.exs
│   ├── error/                # Error handling
│   │   ├── html.ex
│   │   └── html_test.exs
│   ├── components/           # Reusable UI components
│   │   └── core.ex
│   ├── templates/            # Static templates
│   │   └── home/
│   ├── home.ex               # Home controller and templates
│   └── home_test.exs
├── oauth.ex                  # OAuth protocol definition
└── web.ex                    # Web context utilities
```

## Key Architectural Principles

### 1. Domain-Driven Design
- **Contexts** group related functionality (`MyApp.Users`)
- **Schemas** define data structures (`Data.User`)
- **Business logic** stays in context modules, not controllers or LiveViews

### 2. Colocated Testing
- Tests live next to the code they test
- Example: `dashboard_live.ex` and `dashboard_live_test.exs` in same directory
- Easier to maintain and discover tests

### 3. Protocol-Based OAuth
- OAuth functionality defined as protocol in `oauth.ex`
- Multiple implementations: `OAuth.Auth0` (real) and `OAuth.Cache` (caching)
- Easy to mock with `OAuth.Test` for testing
- Configurable providers via application config

### 4. Role-Based Authentication
- Simplified role system: `:admin` and `:user`
- Router-level authentication pipelines
- LiveView access control based on user roles

## Data Flow

```
Request → Router → Pipeline → LiveView/Controller → Context → Schema → Database
                                    ↓
                              OAuth Protocol → Auth0/Cache
```

## Testing Strategy

### Test Categories
1. **Unit Tests**: Individual module functionality
2. **Integration Tests**: LiveView interactions with `Phoenix.LiveViewTest`
3. **Controller Tests**: HTTP request/response testing
4. **Context Tests**: Business logic testing

### Test Configuration
- SQLite for test database (fast, isolated)
- Mox for OAuth mocking
- Factory pattern for test data generation
- Sandbox mode for database isolation

## Authentication Flow

```
1. User visits protected route
2. Router redirects to /auth/auth0
3. Auth0 OAuth flow completes
4. Callback creates/updates user in database
5. Session established with user_id
6. Subsequent requests use session-based auth
```

## Environment Configuration

### Development
- SQLite database
- Live reloading enabled
- Debug information included
- Auth0 credentials from environment

### Test
- Isolated SQLite database per test
- Mocked OAuth providers
- Sandbox database mode
- Fast compilation settings

### Production
- Configurable database (SQLite or Postgres)
- Optimized asset compilation
- Environment-based secrets
- Production-ready supervision tree

This architecture provides a solid foundation for building scalable Phoenix LiveView applications with clean separation of concerns and comprehensive testing.

