# What is this?

This is a Ruby on Rails app for calculating tax based on income and NZ tax brackets.
It provides an API endpoint to perform tax calculations and includes a simple homepage where income can be entered to see the calculated tax.

Refer to the [2025 NZ income tax rates for individuals](https://www.ird.govt.nz/income-tax/income-tax-for-individuals/tax-codes-and-tax-rates-for-individuals/tax-rates-for-individuals) for details of the tax brackets used in this app.

## Prerequisites

- Ruby 3
- Rails 7
- PostgreSQL
- Node.js and npm

## Installation

Install this app for local use by following these steps:

```sh
# Clone the repo
git clone <repo-url>
cd tax-calculator # replace <repo-url> with the actual URL

# Install dependencies
bundle install

# Setup the database
rails db:create
rails db:migrate RAILS_ENV=development
rails db:migrate RAILS_ENV=test
```

## Usage

Running the app locally:

```sh
# In one terminal, start the Rails server
rails server

# In another terminal, start the Vite dev server
npm run dev

# Visit http://localhost:3000
```

Running tests:

```sh
# Run RSpec tests
bundle exec rspec
```

## Assumptions

* We store currency amounts in cents as integers to avoid floating-point precision issues.
As a result, we assume that we can convert between "dollars" and "cents" (or whatever major and minor units the currency in question has) by multiplying/dividing by a power of 10.

## Possible Improvements

There's a number of areas where this app could be improved if it were to be developed for production:

* Add authentication and user management.
* Add more error handling and validation.
* The app/controllers/api/v1/tax_calculation_controller.rb is getting a bit fat and could be refactored to move some of the logic into service objects or contexts.
* Improve the frontend with better styling and user experience.
* As the tax bracket data and currency data doesn't change very often, we could add caching to improve performance.
* Add support for different tax schedules relating to different tax years.
* Add support for more jurisdictions and their respective tax brackets.
* Add more detailed logging and monitoring.
* Properly dockerise this app so it can be run with the prerequisites.
* Add CI/CD pipeline for automated testing and deployment.

## Development Process

We set this app up as follows:

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

# Add the seed data for the tax brackets and currency
rails db:seed

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

# install tailwind and create configs
npm i -D tailwindcss@3 postcss autoprefixer
npx tailwindcss init -p
```
