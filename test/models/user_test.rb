require 'test_helper'
require 'digest/sha1'

class UserTest < ActiveSupport::TestCase
  test "user password gets encrypted upon saving" do
    password = 'password'
    encrypted_password = Digest::SHA1.hexdigest(password)

    test_user = User.create :name => 'test_name', :password => password

    assert_equal(encrypted_password, test_user.password)
  end

  test "login returns user when name and password are correct" do
    password = 'password'
    created_user = User.create :name => 'test_name', :password => password
    logged_in_user = User.login('test_name', password)

    assert_equal(logged_in_user, created_user)
  end

  test "login returns nil when name is not correct" do
    password = 'password'
    created_user = User.create :name => 'test_name', :password => password
    logged_in_user = User.login('random_name', password)

    assert_nil(logged_in_user, created_user)
  end

  test "login returns nil when password is not correct" do
    password = 'password'
    created_user = User.create :name => 'test_name', :password => password
    logged_in_user = User.login('test_name', 'random_password')

    assert_nil(logged_in_user, created_user)
  end

  test "error returned when user does not have an account" do
    created_user = User.create :name => 'test_name', :password => 'password'
    expected_error_message = "Your account could not be found"
    
    result = created_user.transfer("4c88305f-4bbc-4b5c-ba77-b4ac7f0e1bb3", 'transferee_name', 10)

    assert_equal(expected_error_message, result)
  end

  test "error returned when amount is not positive" do
    created_user = User.create :name => 'test_name', :password => 'password'
    user_account = Account.create :user => created_user
    expected_error_message = "Transfer amount must be positive. You entered -1"
    
    result = created_user.transfer("4c88305f-4bbc-4b5c-ba77-b4ac7f0e1bb3", 'transferee_name', -1)

    assert_equal(expected_error_message, result)
  end

  test "error returned when transferee does not exist" do
    created_user = User.create :name => 'test_name', :password => 'password'
    user_account = Account.create :user => created_user
    expected_error_message = "Could not find user with name transferee_name"
    
    result = created_user.transfer("4c88305f-4bbc-4b5c-ba77-b4ac7f0e1bb3", 'transferee_name', 10)

    assert_equal(expected_error_message, result)
  end

  test "error returned when transferee account can not be found" do
    transfer_user = User.create :name => 'make_transfer', :password => 'password'
    transfee_user = User.create :name => 'get_transfer', :password => 'password'
    transfer_account = Account.create :user => transfer_user
    transferee_account = Account.create :user => transfee_user
    expected_error_message_incorrect_account_id = "Could not find account for user with name get_transfer and account_id 4c88305f-4bbc-4b5c-ba77-b4ac7f0e1bb3"
    expected_error_message_incorrect_name = "Could not find account for user with name random_name and account_id #{transferee_account.account_id}"
    
    result_incorrect_account_id = transfer_user.transfer("4c88305f-4bbc-4b5c-ba77-b4ac7f0e1bb3", transfee_user.name, 10)
    result_incorrect_name = transfer_user.transfer(transferee_account.account_id, 'random_name', 10)

    assert_equal(expected_error_message_incorrect_account_id, result_incorrect_account_id)
    assert_equal(expected_error_message_incorrect_name, expected_error_message_incorrect_name)
  end

  test "error returned when transferer does not enough in their account" do
    transfer_user = User.create :name => 'make_transfer', :password => 'password'
    transfee_user = User.create :name => 'get_transfer', :password => 'password'
    transfer_account = Account.create :user => transfer_user, :balance => 5
    transferee_account = Account.create :user => transfee_user
    expected_error_message = "You do not have enough to transfer 10.  Your current balance is 5.0"
    
    result = transfer_user.transfer(transferee_account.account_id, transfee_user.name, 10)

    assert_equal(expected_error_message, result)
  end

  test "transfer instance created for successful transfer and account balances accurate" do
    transfer_user = User.create :name => 'make_transfer', :password => 'password'
    transfee_user = User.create :name => 'get_transfer', :password => 'password'
    transfer_account = Account.create :user => transfer_user, :balance => 20
    transferee_account = Account.create :user => transfee_user
    
    result = transfer_user.transfer(transferee_account.account_id, transfee_user.name, 5)

    assert_not_nil(result.id)
    assert_equal(Account.find(transfer_account.id).balance, 15)
    assert_equal(Account.find(transferee_account.id).balance, 5)
  end

  test "check_password_complexity returns true if password is complex enough" do
      assert_equal(true, User.check_password_complexity('P@ssw0rd!'))
  end

  test "check_password_complexity returns false if password does not have uppercase letter" do
      assert_equal(false, User.check_password_complexity('p@ssw0rd!'))
  end

  test "check_password_complexity returns false if password does not have lowercase letter" do
      assert_equal(false, User.check_password_complexity('P@SSW0RD!'))
  end

  test "check_password_complexity returns false if password does not have number" do
      assert_equal(false, User.check_password_complexity('P@ssword!'))
  end

  test "check_password_complexity returns false if password does not have special character" do
      assert_equal(false, User.check_password_complexity('Passw0rd'))
  end
end
