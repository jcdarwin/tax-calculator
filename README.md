# What is this?

This is a Ruby on Rails app for calculating tax based on income and tax brackets. It provides an API endpoint to perform tax calculations and includes a simple homepage where income can be entered to see the calculated tax.

# Prerequisites

- Ruby 3
- Rails 7
- PostgreSQL
- Node.js and npm (for Vite and Tailwind CSS)

# Installation

```sh
# Clone the repo
git clone <repo-url>
cd tax-calculator # replace <repo-url> with the actual URL

# Install dependencies
bundle install

# Setup the database
bin/rails db:create
bin/rails db:migrate RAILS_ENV=development
bin/rails db:migrate RAILS_ENV=test
```

# Usage

Running the app locally:

```sh
# Start the Rails server
rails server

# Visit http://localhost:3000
```

Running tests:

```sh
# Run RSpec tests
bundle exec rspec
```

# Setup

```sh
# Create a new Rails app with Tailwind CSS
rails new tax-calculator --minimal --css=tailwind
cd tax-calculator

# Initialize a git repo
git init

# Add our homepage controller
rails g controller Homepage index

# Add the gems to the Gemfile that we'll need
# - pg
# - rspec-rails
# - vite_rails

# Install the gems
bundle install

# Setup the db in config/database.yml and create the db
bin/rails db:create

# Add the migrations and fill them out
rails generate migration CreateTaxBrackets
rails generate migration CreateTaxCalculations

# Apply the migrations
rails db:migrate RAILS_ENV=development
rails db:migrate RAILS_ENV=test

# Add the models and fill them out
rails generate model Currency
rails generate model TaxBracket

# Fill out the model specs and run the tests
bundle exec rspec

# Add the controllers and fill them out
mkdir -p app/controllers/api/v1
touch app/controllers/api/v1/tax_calculation_controller.rb

# Add the request specs and fill them out
mkdir -p spec/requests/api/v1
touch spec/requests/api/v1/tax_calculation_spec.rb

# Run the tests using TDD (repeatedly until we get them passing)
bundle exec rspec

# configure Vite
bundle exec vite install

# Add an alias for the vite dev server to package.json
  "scripts": {
    "dev": "bin/vite dev"
  }

# Run the Vite dev server
npm run dev

# Add react
npm install react react-dom @vitejs/plugin-react
```
