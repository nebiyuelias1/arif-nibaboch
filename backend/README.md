# Backend - Rails 8 API

This is the backend Rails application for the Turbo Rails + React Native starter project. It provides a Turbo-enabled API and web interface that integrates seamlessly with the React Native mobile app.

## Tech Stack

- **Ruby**: 3.4.6
- **Rails**: 8.0.3
- **Database**: SQLite
- **Frontend**: Turbo Rails, Stimulus, Tailwind CSS
- **Authentication**: Devise
- **Background Jobs**: Solid Queue
- **Caching**: Solid Cache
- **WebSockets**: Solid Cable (Action Cable)
- **Asset Pipeline**: Propshaft
- **Deployment**: Kamal

## Prerequisites

- Ruby 3.4.6 (see `.ruby-version`)
- SQLite
- Node.js and Yarn (for asset compilation)
- Docker and Docker Compose (optional, for containerized development)

## Getting Started

### Option 1: Local Development (Without Docker)

1. **Install Ruby dependencies**

   ```bash
   bundle install
   ```

2. **Set up the database**

   ```bash
   # Create database
   rails db:create
   
   # Run migrations
   rails db:migrate
   
   # Seed database (optional)
   rails db:seed
   ```

3. **Start the development server**

   ```bash
   # Start Rails server with Tailwind CSS watcher
   bin/dev
   ```

4. **Access the application**

   Open your browser and navigate to: `http://localhost:3000`

### Option 2: Development with Docker (Devcontainer)

This project includes a devcontainer configuration for containerized development.

1. **Install devcontainer CLI**

   ```bash
   npm install -g @devcontainers/cli
   ```

2. **Build the devcontainer**

   ```bash
   devcontainer up --workspace-folder .
   ```

3. **Enter the container**

   ```bash
   devcontainer exec --workspace-folder . bash
   ```

4. **Set up database and start server**

   ```bash
   # Inside the container
   rails db:create db:migrate
   bin/dev
   ```

5. **Access the application**

   The app will be running at: `http://localhost:3000`

## Configuration

### Environment Variables

Create a `.env` file in the backend directory if you need custom environment variables:

```bash
DATABASE_URL=postgresql://user:password@localhost/turbo_rails_dev
RAILS_ENV=development
```

### Database Configuration

Database settings are configured in `config/database.yml`. By default, it uses SQLite with the following connection:

- Development: `turbo_rails_development`
- Test: `turbo_rails_test`
- Production: Uses DATABASE_URL environment variable

## Testing

Run the test suite:

```bash
# Run all tests
rails test

# Run specific test file
rails test test/models/user_test.rb

# Run tests in a specific directory
rails test test/models/
```

## Key Features

### Turbo Rails Integration

- Turbo Frames for partial page updates
- Turbo Streams for real-time updates
- Turbo Native compatible endpoints for mobile app

### Authentication

- User authentication via Devise
- API endpoints secured with authentication
- Session management for web and mobile

### Modern Rails 8 Infrastructure

- **Solid Queue**: Background job processing
- **Solid Cache**: Fast caching layer
- **Solid Cable**: WebSocket support for real-time features

## Code Quality & Linting

This project uses [RuboCop Rails Omakase](https://github.com/rails/rubocop-rails-omakase) (official Rails 8 styling), [erb-lint](https://github.com/Shopify/erb-lint) (ERB template linter), and [Lefthook](https://github.com/evilmartians/lefthook) for automatic Git pre-commit hooks.

```bash
# Check Ruby code for style and lint issues
bundle exec rubocop

# Automatically fix Ruby formatting and linting issues
bundle exec rubocop -A

# Check and autocorrect ERB templates
bundle exec erb_lint --autocorrect app/views/**/*.html.erb

# Run Git pre-commit hooks manually (RuboCop + ERB linters in parallel)
bundle exec lefthook run pre-commit

# Security vulnerability audit
bundle exec brakeman
```

## Development Commands

```bash
# Start development server with all processes
bin/dev

# Rails console
rails console

# Database migrations
rails db:migrate
rails db:rollback

# Generate new resources
rails generate model Post title:string body:text
rails generate controller Posts

# Check routes
rails routes
```

## Deployment

This project uses Kamal for deployment. See `config/deploy.yml` for deployment configuration.

```bash
# Setup deployment
kamal setup

# Deploy application
kamal deploy

# Check app status
kamal app status
```

## Useful Resources

- [Rails Guides](https://guides.rubyonrails.org/)
- [Turbo Rails Documentation](https://turbo.hotwired.dev/)
- [Tailwind CSS](https://tailwindcss.com/)
- [Devise Documentation](https://github.com/heartcombo/devise)

## Troubleshooting

### Asset Compilation Issues

```bash
# Clear assets cache
rails assets:clobber

# Precompile assets
rails assets:precompile
```

## Need Help?

Refer to the main project [README](../README.md) for general information and links to mobile app documentation.
