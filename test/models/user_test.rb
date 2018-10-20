require 'test_helper'
require 'digest/sha1'

class UserTest < ActiveSupport::TestCase
  test "user password gets encrypted upon saving" do
    password = 'password'
    encrypted_password = Digest::SHA1.hexdigest(password)

    test_user = User.create :name => 'test_name', :password => password

    assert_equal(encrypted_password, test_user.password)
  end
end
