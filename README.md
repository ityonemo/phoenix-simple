# MyApp

A simplified Phoenix application starter template with Auth0 integration and role-based authentication.

The file architecture for this is dramatically different from the default Phoenix Generated experience,
and is optimized for domain-based organization.

Optimized with dual workflow (sqlite/postgres) for phoenix.new vibecoding experiences.

## Features

- **Role-based Authentication**: Admin and User roles with different access levels
- **Auth0 Integration**: Secure OAuth authentication flow
- **Phoenix LiveView**: Real-time, interactive web application
- **Tailwind CSS**: Modern, responsive styling
- **SQLite Database**: Lightweight database for development
- **Comprehensive Test Suite**: Full test coverage with colocated tests

## Getting Started

### Prerequisites

- Elixir 1.15+
- Phoenix 1.8+
- Node.js (for asset compilation)

### Installation

1. Clone the repository:
```bash
git clone <repository-url>
cd my_app
```

2. Install dependencies:
```bash
mix deps.get
```

3. Set up the database:
```bash
mix ecto.setup
```

4. Configure Auth0 (see Auth0 Setup section below)

5. Start the server:
```bash
./start_server.sh
```

Visit [`localhost:4000`](http://localhost:4000) to see the application.

### Auth0 Setup

Create a `config/.env` file with your Auth0 credentials:

```bash
export AUTH0_DOMAIN=your-domain.auth0.com
export AUTH0_CLIENT_ID=your_client_id
export AUTH0_CLIENT_SECRET=your_client_secret
export AUTH0_REDIRECT_URI=http://localhost:4000/auth/callback
export AUTH0_HOME_URI=http://localhost:4000
```

### Running Tests

```bash
mix test
```

(if you're in the phoenix.new environment or prefer sqlite)

```bash
DATABASE_ADAPTER=sqlite mix test
```

## Architecture

This application uses a domain-driven architecture with:

- **Context modules** in `lib/my_app/`
  these contain business logic:
  - pubsub notifications (if applicable)
  - accounting/mathematical transformations
  - role logic
  - specific business-based data access patterns
- **Web layer** in `lib/web/`
  - all live- and dead- views, organized by domain and not "type of page"
- **Data layer** in `lib/data/`
  data modules should contain:
  - database access
  - table caches (if applicable)
- **OAuth integration** in `lib/oauth/`

## User Roles

- **Admin**: Full system access, user management
- **User**: Standard user access to personal dashboard

## Development

### Code Quality

```bash
mix credo --strict
```

### Database

The application uses Postgres by default. To use sqlite:

```bash
DATABASE_ADAPTER=sqlite mix compile
```

## License

This project is available as open source under the terms of the MIT License.

