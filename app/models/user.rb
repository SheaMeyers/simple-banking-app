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

	def transfer(transfer_to_name, amount)
		user_account = Account.find_by(user_id: self.id)

		if (user_account == nil)
			return  "Your account could not be found"
		end

		if (amount<0.01)
			return "Transfer amount must be positive. You entered #{amount}"
		end

		transferee_user = User.find_by(name: transfer_to_name)
		
		if (transferee_user == nil)
			return  "Could not find user with name #{transfer_to_name}"
		end

		transferee_account = Account.find_by(user_id: transferee_user.id)

		if (transferee_account == nil)
			return "Could not find account for user with name #{transfer_to_name}"
		end

		if (amount>user_account.balance)
			return "You do not have enough to transfer #{amount}.  Your current balance is #{user_account.balance}"
		end 

		user_account.balance = user_account.balance - amount
		user_account.save

		transferee_account.balance = transferee_account.balance + amount
		transferee_account.save

		return Transfer.create :transferer => self.name, :transferee => transferee_user.name, :amount => amount
	end
end
