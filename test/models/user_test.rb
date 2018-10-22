require 'test_helper'
require 'digest/sha1'

class UserTest < ActiveSupport::TestCase
  test "user name can not be empty" do
    test_user_no_name = User.create :name => '', :password => 'password'
    test_user_name_space = User.create :name => ' ', :password => 'password'
    test_user_name_tab = User.create :name => ' ', :password => 'password'

    assert_nil(test_user_no_name.id)
    assert_nil(test_user_name_space.id)
    assert_nil(test_user_name_tab.id)
  end

  test "user password gets encrypted upon saving" do
    password = 'P@ssw0rd!'
    encrypted_password = Digest::SHA1.hexdigest(password)

    test_user = User.create :name => 'test_name', :password => password

    assert_equal(encrypted_password, test_user.password)
  end

  test "login returns user when name and password are correct" do
    password = 'P@ssw0rd!'
    created_user = User.create :name => 'test_name', :password => password
    logged_in_user = User.login('test_name', password)

    assert_equal(logged_in_user, created_user)
  end

  test "login returns nil when name is not correct" do
    password = 'P@ssw0rd!'
    created_user = User.create :name => 'test_name', :password => password
    logged_in_user = User.login('random_name', password)

    assert_nil(logged_in_user, created_user)
  end

  test "login returns nil when password is not correct" do
    password = 'P@ssw0rd!'
    created_user = User.create :name => 'test_name', :password => password
    logged_in_user = User.login('test_name', 'The_P@ssw0rd!')

    assert_nil(logged_in_user, created_user)
  end

  test "error returned when user does not have an account" do
    created_user = User.create :name => 'test_name', :password => 'P@ssw0rd!'
    expected_error_message = "Your account 42a69812-a829-4faa-874c-2d0f8e835ba3 could not be found"
    
    result = created_user.transfer("42a69812-a829-4faa-874c-2d0f8e835ba3", "4c88305f-4bbc-4b5c-ba77-b4ac7f0e1bb3", 'transferee_name', 10)

    assert_equal(expected_error_message, result)
  end

  test "error returned when amount is not positive" do
    created_user = User.create :name => 'test_name', :password => 'P@ssw0rd!'
    user_account = Account.create :user => created_user
    expected_error_message = "Transfer amount must be positive. You entered -1"
    
    result = created_user.transfer(user_account.account_id, "4c88305f-4bbc-4b5c-ba77-b4ac7f0e1bb3", 'transferee_name', -1)

    assert_equal(expected_error_message, result)
  end

  test "error returned when transferee does not exist" do
    created_user = User.create :name => 'test_name', :password => 'P@ssw0rd!'
    user_account = Account.create :user => created_user
    expected_error_message = "Could not find user with name transferee_name"
    
    result = created_user.transfer(user_account.account_id, "4c88305f-4bbc-4b5c-ba77-b4ac7f0e1bb3", 'transferee_name', 10)

    assert_equal(expected_error_message, result)
  end

  test "error returned when transferee account can not be found" do
    transfer_user = User.create :name => 'make_transfer', :password => 'P@ssw0rd!'
    transfee_user = User.create :name => 'get_transfer', :password => 'P@ssw0rd!'
    transfer_account = Account.create :user => transfer_user
    transferee_account = Account.create :user => transfee_user
    expected_error_message_incorrect_account_id = "Could not find account for user with name get_transfer and account_id 4c88305f-4bbc-4b5c-ba77-b4ac7f0e1bb3"
    expected_error_message_incorrect_name = "Could not find account for user with name random_name and account_id #{transferee_account.account_id}"
    
    result_incorrect_account_id = transfer_user.transfer(transfer_account.account_id, "4c88305f-4bbc-4b5c-ba77-b4ac7f0e1bb3", transfee_user.name, 10)
    result_incorrect_name = transfer_user.transfer(transfer_account.account_id, transferee_account.account_id, 'random_name', 10)

    assert_equal(expected_error_message_incorrect_account_id, result_incorrect_account_id)
    assert_equal(expected_error_message_incorrect_name, expected_error_message_incorrect_name)
  end

  test "error returned when transferer does not enough in their account" do
    transfer_user = User.create :name => 'make_transfer', :password => 'P@ssw0rd!'
    transfee_user = User.create :name => 'get_transfer', :password => 'P@ssw0rd!'
    transfer_account = Account.create :user => transfer_user, :balance => 5
    transferee_account = Account.create :user => transfee_user
    expected_error_message = "You do not have enough to transfer 10.  Your current balance is 5.0"
    
    result = transfer_user.transfer(transfer_account.account_id, transferee_account.account_id, transfee_user.name, 10)

    assert_equal(expected_error_message, result)
  end

  test "transfer instance created for successful transfer and account balances accurate" do
    transfer_user = User.create :name => 'make_transfer', :password => 'P@ssw0rd!'
    transfee_user = User.create :name => 'get_transfer', :password => 'P@ssw0rd!'
    transfer_account = Account.create :user => transfer_user, :balance => 20
    transferee_account = Account.create :user => transfee_user
    
    result = transfer_user.transfer(transfer_account.account_id, transferee_account.account_id, transfee_user.name, 5)

    assert_not_nil(result.id)
    assert_equal(Account.find(transfer_account.id).balance, 15)
    assert_equal(Account.find(transferee_account.id).balance, 5)
  end

  test "user created when password is complex enough" do
      test_user = User.create :name => 'name', :password => 'P@ssw0rd!'
      assert_not_nil(test_user.id)
  end

  test "user not created when password does not have uppercase letter" do
      test_user = User.create :name => 'name', :password => 'p@ssw0rd!'
      assert_nil(test_user.id)
  end

  test "user not created when password does not have lowercase letter" do
      test_user = User.create :name => 'name', :password => 'P@SSW0RD!'
      assert_nil(test_user.id)
  end

  test "user not created when password does not have number" do
      test_user = User.create :name => 'name', :password => 'P@ssword!'
      assert_nil(test_user.id)
  end

  test "user not created when password password does not have special character" do
      test_user = User.create :name => 'name', :password => 'Passw0rd'
      assert_nil(test_user.id)
  end
end
