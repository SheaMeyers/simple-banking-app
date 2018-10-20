class Account < ApplicationRecord
  belongs_to :user
  # Enforce one user having one account
  validates :user_id, presence: true
  validates :user_id, uniqueness: true
  validates :balance, :numericality => { :greater_than_or_equal_to => 0 }
end
