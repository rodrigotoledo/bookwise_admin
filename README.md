# Book Management System (Rails 8 API)

![Ruby](https://img.shields.io/badge/Ruby-3.4+-CC342D?logo=ruby&logoColor=white)
![Rails](https://img.shields.io/badge/Rails-8.0+-CC0000?logo=ruby-on-rails&logoColor=white)
![RSpec](https://img.shields.io/badge/RSpec-3.12+-FF0000?logo=rubygems&logoColor=white)
![CI/CD](https://img.shields.io/badge/CI/CD-Github_Actions-2088FF?logo=github-actions&logoColor=white)

Rails 8 API for book inventory, rentals, and returns management with SimpleCSS frontend and real-time features.

## Key Technologies

- **Ruby 3.4**
- **Rails 8.0** (API Mode)
- **Sqlite** (database)
- **SimpleCSS** (lightweight frontend)
- **RSpec** (testing framework)
- **Rubocop** + **Brakeman** (static analysis)
- **Guard** (automatic test runner)
- **GitHub Actions** (CI/CD pipeline)

## Getting Started

### Prerequisites

- Ruby 3.4+
- Rails 8.0+
- Sqlite

### Installation

1. **Clone the repository**

```bash
git clone git@github.com:rodrigotoledo/bookwise_admin.git
```

2. **Setup environment**

```bash
cd bookwise_admin
cp .env.example .env
```

3. **Initialize database**

```bash
bin/rails db:setup
```

4. **Run the application**

```bash
bin/dev_local # Starts server with Rubocop & Brakeman checks
```

The API will be available at http://localhost:3000

### Development

#### Running Tests

```bash
bundle exec guard # Auto-runs tests on file changes
```

Or run manually:

```bash
bundle exec rspec
```

## API Endpoint Coverage

- User Authentication and Authorization
- Book Management (CRUD)
- Borrowing System
- Return Management
