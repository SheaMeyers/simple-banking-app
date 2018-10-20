class CreateAccounts < ActiveRecord::Migration[5.2]
  def change
    create_table :accounts do |t|
      t.decimal :amount, :precision => 12, :scale => 2, :default => 0.00
      t.references :user, foreign_key: true

      t.timestamps
    end
  end
end
