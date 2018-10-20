require 'digest/sha1'

class User < ApplicationRecord
	has_one :account

	def save
		self.password = Digest::SHA1.hexdigest(password)
		super
	end 

	def self.login(name, password)
		encrypted_password = Digest::SHA1.hexdigest(password)
		user = User.find_by(name: name, password: encrypted_password)

		if (user == nil)
			puts "Warning: Incorrect name or password"
		end

		return user
	end
end
