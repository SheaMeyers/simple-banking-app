require 'digest/sha1'

class User < ApplicationRecord

	def check_password_complexity(password)
		# Checks that a password has at least one uppercase letter, one lowercase letter,
		#   one number and one password
		# param: password: the password to check
		# return: True if the password meets complexity requirements, False otherwise

		if (password =~ /^(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9])(?=.*?[#?!@$%^&*-]).{8,70}$/)
			return true 
		else
			return false
		end
	end

	def save
		# Override the save method in order to encrypt the user's password and check password complexity

		if (not self.name.present?)
			puts "Name cannot be empty"
			return 
		end

		if not self.check_password_complexity(password)
			puts "Password must contain one uppercase letter, one lowercase letter, one number, and one special character"
			return 
		end

		self.password = Digest::SHA1.hexdigest(password)
		super
	end 

	def self.login(name, password)
		# Login a user
		# param: name: the name of the user
		# param: password: the password of the user
		# return: The user if successfully logged in, otherwise nil

		encrypted_password = Digest::SHA1.hexdigest(password)
		user = User.find_by(name: name, password: encrypted_password)

		if (user == nil)
			puts "Warning: Incorrect name or password"
		end

		return user
	end

	def transfer(transfer_to_account_id, transfer_to_name, amount)
		# Transfer money from this user to the user specified
		# param: transfer_to_account_id: the account id of the account you're transfering to
		# param: transfer_to_name: the name of the user you're transferring money to
		# param: amount: the amount of money you will be transferring
		# return: An instance of the Transfer model if successful, other an error message

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

		transferee_account = Account.find_by(user_id: transferee_user.id, account_id: transfer_to_account_id)

		if (transferee_account == nil)
			return "Could not find account for user with name #{transfer_to_name} and account_id #{transfer_to_account_id}"
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
