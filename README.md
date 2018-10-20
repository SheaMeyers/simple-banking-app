# Simple Banking App

This is a prototype of a banking application.  Through this application you can create Users and Accounts and transfer money between accounts.

## Dependencies

ruby = 2.5.1

rails = 5.2.1

sqlite3 = 3.19.4

## System Dependencies

This was developed on a Macbook Pro with the operating system High Sierra.  However it is expected to work on any system that fulfils the above dependencies

## Configuration and Database Creation

Clone this repository and `cd` into `simple-banking-app`

Run the command `bundle install` to install all required Gems

Run the command `rake db:reset` (or commands `rake db:create` and `rake db:migrate`) to initialize the database

Optional: You can run the command `rake db:fixtures:load` to load the fixtures defined in `/test/fixtures/`

## Test Suite

Run the command `bin/rails test` to run the test suite
