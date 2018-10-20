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
end
