class CreateTransfers < ActiveRecord::Migration[5.2]
  def change
    create_table :transfers do |t|
      t.string :transferer
      t.string :transferee
      t.decimal :amount, :precision => 9, :scale => 2

      t.timestamps
    end
  end
end
