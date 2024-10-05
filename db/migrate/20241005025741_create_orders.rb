class CreateOrders < ActiveRecord::Migration[7.2]
  def change
    create_table :orders do |t|
      t.decimal :amount
      t.string :status

      t.timestamps
    end
  end
end
