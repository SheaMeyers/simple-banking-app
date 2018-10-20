class Account < ApplicationRecord
  belongs_to :user
  # Enforce one user having one account
  validates :oneuser_id, presence: true
  validates :oneuser_id, uniqueness: true
end
