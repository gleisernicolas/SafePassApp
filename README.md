# SafePassApp

A password manager application built as a learning project to explore and understand **Hotwire (Turbo + Stimulus)** and modern Rails development practices.

## About This Project

This project was created for educational purposes to study and learn more about:
- **Hotwire/Turbo**: Building reactive, SPA-like experiences without writing much JavaScript
- **Stimulus**: Adding sprinkles of JavaScript interactivity where needed
- **Rails 8**: Exploring the latest Rails features and conventions
- **Modern Rails architecture**: Using Solid Cache, Solid Queue, and Solid Cable

## Features

- User authentication with Devise
- Secure password storage and management
- Real-time updates with Turbo Streams
- Interactive UI with Stimulus controllers
- API with JWT authentication
- Responsive design with Bootstrap

## Tech Stack

- **Ruby**: 3.4.7
- **Rails**: 8.1.2
- **Database**: PostgreSQL
- **Frontend**: Hotwire (Turbo + Stimulus), Bootstrap 5
- **Authentication**: Devise, JWT
- **Asset Pipeline**: esbuild, Propshaft
- **CSS**: Sass with Bootstrap

## Resources & Documentation

### Hotwire
- [Hotwire Official Site](https://hotwired.dev/)
- [Turbo Handbook](https://turbo.hotwired.dev/handbook/introduction)
- [Turbo Reference](https://turbo.hotwired.dev/reference/frames)
- [Stimulus Handbook](https://stimulus.hotwired.dev/handbook/introduction)
- [Stimulus Reference](https://stimulus.hotwired.dev/reference/controllers)

### Rails & Related
- [Rails 8 Guides](https://guides.rubyonrails.org/)
- [Devise Documentation](https://github.com/heartcombo/devise)
- [Bootstrap 5 Documentation](https://getbootstrap.com/docs/5.3/getting-started/introduction/)

### Learning Resources
- [Hotwire Dev Newsletter](https://hotwired.dev/)
- [GoRails Hotwire Tutorials](https://gorails.com/series/hotwire-rails)
- [Turbo Rails Tutorial](https://www.hotrails.dev/turbo-rails)

## Prerequisites

Before running this project, make sure you have the following installed:

- **Ruby** 3.4.7 (use rbenv or rvm)
- **Node.js** 18+ and Yarn
- **PostgreSQL** 14+
- **Redis** (for Action Cable and caching)

## Getting Started

### 1. Clone the Repository

```bash
git clone <repository-url>
cd SafePassApp
```

### 2. Install Dependencies

```bash
# Install Ruby gems
bundle install

# Install JavaScript dependencies
yarn install
```

### 3. Database Setup

```bash
# Create the database
rails db:create

# Run migrations
rails db:migrate

# (Optional) Seed the database with sample data
rails db:seed
```

### 4. Configure Environment Variables

Create a `.env` file in the root directory if needed for any custom configuration. The default development settings should work out of the box.

### 5. Start the Development Server

The project uses `bin/dev` to start all necessary services (Rails server, CSS watcher, JS builder):

```bash
bin/dev
```

This will start:
- Rails server on `http://localhost:3000`
- CSS compilation watcher
- JavaScript bundling with esbuild

Alternatively, you can run services individually:

```bash
# Rails server only
rails server

# CSS watcher (in another terminal)
yarn watch:css

# JavaScript build (in another terminal)
yarn build --watch
```

### 6. Access the Application

Open your browser and navigate to:
```
http://localhost:3000
```

## Running Tests

This project uses **RSpec** with FactoryBot, Faker, and Shoulda Matchers.

```bash
# Run all tests
bundle exec rspec

# Run with documentation format
bundle exec rspec --format documentation

# Run specific test file
bundle exec rspec spec/models/entry_spec.rb

# Run specific test by line number
bundle exec rspec spec/models/entry_spec.rb:25
```

### Test Coverage

- **Model specs**: User and Entry models with validations, associations, and encryption
- **Request specs**: EntriesController, PagesController, API controllers
- **Service specs**: JsonWebToken encoding/decoding

### Testing Libraries

- **RSpec**: Testing framework
- **FactoryBot**: Test data factories
- **Faker**: Realistic fake data generation
- **Shoulda Matchers**: One-liner tests for common Rails patterns

## Project Structure

```
app/
├── controllers/        # Rails controllers
│   ├── api/v1/        # API endpoints with JWT auth
│   └── entries_controller.rb
├── javascript/        # Stimulus controllers and JS
│   ├── controllers/   # Stimulus controllers
│   └── utils/         # Helper functions
├── models/            # ActiveRecord models
├── views/             # ERB templates with Turbo
└── assets/            # Stylesheets and images

config/
├── routes.rb          # Application routes
└── database.yml       # Database configuration
```

## Key Hotwire Concepts Used

### Turbo Frames
Turbo Frames allow independent parts of the page to be updated without full page reloads.

### Turbo Streams
Used for real-time updates (create, update, delete operations) with server-rendered HTML.

### Stimulus Controllers
Small JavaScript controllers that add interactivity:
- `toggle_password_controller.js` - Toggle password visibility
- `clipboard_controller.js` - Copy to clipboard functionality
- `search_controller.js` - Real-time search filtering
- `toast_controller.js` - Toast notifications

## Troubleshooting

### Database Connection Issues
```bash
# Make sure PostgreSQL is running
brew services start postgresql

# Check database configuration in config/database.yml
```

### Asset Compilation Issues
```bash
# Clear assets cache
rails assets:clobber

# Rebuild assets
yarn build
yarn build:css
```

### Port Already in Use
```bash
# Kill process on port 3000
lsof -ti:3000 | xargs kill -9
```

## Contributing

This is a learning project, but suggestions and feedback are welcome! Feel free to open issues or submit pull requests.

## License

This project is open source and available for educational purposes.
