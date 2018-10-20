require 'digest/sha1'

class User < ApplicationRecord
	has_one :account

	def save
		self.password = Digest::SHA1.hexdigest(password)
		super
	end 
end
