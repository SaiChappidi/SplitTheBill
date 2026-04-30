# Final Project: Split The Bill - Group No Sin Da Woo

## Overview
This project is a Ruby on Rails application for organizing trips and splitting shared expenses among participants. The website lets users create trips, add expenses, choose who shares each expense, and review balances and settlement suggestions.

## Features
- Create and manage trips with participants
- Add, edit, and delete shared expenses
- Split expenses across all participants or only selected participants
- Enter custom amounts per person for each expense
- View expense totals, balances, and settlement suggestions
- Filter and search expenses on the trip page

## File Structure
```text
.
├── app/
│   ├── controllers/
│   ├── models/
│   ├── views/
│   ├── assets/
│   └── javascript/
├── config/
├── db/
├── test/
├── bin/
├── Gemfile
└── README.md
```

## Ruby Version
- Ruby `3.3.5`

## System Dependencies
- Ruby on Rails `8.1.3`
- SQLite3
- No npm is required to run the app

## Configuration
Install the Ruby gems:
```bash
bundle install
```

Create the database:
```bash
bin/rails db:create
```

Run the migrations:
```bash
bin/rails db:migrate
```

## How to Run
Start the app in development with:
```bash
bin/dev
```
You can also run the Rails server directly:
```bash
bin/rails server
```

## How to Run the Test Suite
Run the tests with:
```bash
bin/rails test
```

## Services
This project uses built-in Rails services for background jobs, caching, and Action Cable through the Solid suite configured in the Rails app.

## Deployment Instructions
The application is configured for Docker deployment.

To build the production image:
```bash
docker build -t nosindawoo_final_project .
```

To run it in production, provide `RAILS_MASTER_KEY` and start the container as described in the `Dockerfile`.
