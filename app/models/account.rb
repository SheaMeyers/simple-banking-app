class Account < ApplicationRecord
  belongs_to :user

  # Enforce the balance being positive
  validates :balance, :numericality => { :greater_than_or_equal_to => 0 }

  def save
		# Override the save method in order to set a random account_id

		self.account_id = SecureRandom.uuid
		super
	end 
end
