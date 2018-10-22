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

Run the command `rake db:setup` and `rake db:migrate` to initialize the database

Optional: You can run the command `rake db:fixtures:load` to load the fixtures defined in `/test/fixtures/`

## Test Suite

Run the command `bin/rails test` to run the test suite


# Running and Testing

This section will cover the running and testing of the app and will reference points from the assignment

After running `rails c` you will be in a rails console.  From the console you can test the app

## 2. Via the console you can create users with password

You can create users using `User.create`
An example:
```ruby
user = User.create :name => 'the_name', :password => 'P@ssw0rd!'
```

## 3. User can log in

You can log into a user using `User.login` 
An example:
```ruby
user = User.login('the_name', 'P@ssw0rd!')
```

This will return the user instance if the log in is successful and `nil` if the log in is not successful

## 4. Via the console you can give the user credit

To do this you will need to use the `Admin` user or some other user and use the `transfer` method.  To keep with the idea that money can not just appear in an account it must be transfered.  

Note: Fixtures are created with a balance other than 0 for testing purposes

Here is an example of giving a user credit
```ruby
user = User.login('Admin', '@Dm1n')
user.transfer('6f429e02-3f61-4be0-b576-d404647a2c70', '977d37ae-f759-49c6-af79-0be1e39e75e5', 'Shea', 10)
```

## 5. User has a bank account with balance.

Users have an Account (after the account is created).

Here is an example of creating an account
```ruby
user = User.create :name => 'name', :password => 'P@ssw0rd!'
account = Account.create :user => user  # Note: One attribute, user, which expects a User instance
```

## 6. Users can transfer money to each other.

There is a `transfer` method on the user instance that can be used to transfer money.

Here is an example
```ruby
user = User.login('Admin', '@Dm1n')
user.transfer('6f429e02-3f61-4be0-b576-d404647a2c70', '977d37ae-f759-49c6-af79-0be1e39e75e5', 'Shea', 10)
``` 

## 7. Users may not have a negative balance on their account.

There is a check for this in the `transfer` method to ensure users do not transfer more money than they have and this is also enforced on the `Account` model

## 8. We need to figure out how a user obtained a certain balance.

Anytime the `transfer` method is called an instance of the `Transfer` model is created.  An instance contains the user who is transfering the money, the user that is receiving the money, and the amount of money transfered.  Therefore we can look at the instance of the `Transfer` model where the user is the transferer and transferee to determine how they obtained a certain balance. 

## 9. It is important that money cannot just disappear or appear into account.

See Point 8 above, same comment applies.


# General Remarks 

## Single currency

There is no specified currency in the app and it's assume that everyone is using a single currency.  In the real world this obviously isn't true. If we wanted to implement multiple currencies we could add a `currency` attribute to the account and have a model to handle conversions between different currencies.

## Password Encryption

This app uses `Digest::SHA1.hexdigest` to encrypt password beforing saving.

## Password Complexity

This app requires passwords to have at least one uppercase letter, one lowercase letter, one number, and one special character.

## Negative balance

This app does not allow users to have a negative balance.  In the real world you may be allowed to overdraw your account (thus having a negative balance) however this app does not allow that, though it would be simple to add this functionality.

## Account Id

There is an `account_id` field on the `Account` model, not to be confused with the `id` field.  The `account_id` is a randomly generated uuid and is used when transfering money.  There are two reasons for this.  The first is to have an id that users would not be able to guess.  The second is that this adds extra validation when transferring money by ensuring the person transfering money has the correct `account_id` and `name`.  
