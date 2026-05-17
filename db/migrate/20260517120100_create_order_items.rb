class CreateOrderItems < ActiveRecord::Migration[8.1]
  def change
    create_table :order_items do |t|
      t.references :order, null: false, foreign_key: true
      t.string :sku, null: false
      t.string :name, null: false
      t.integer :quantity, null: false
      t.decimal :price, precision: 12, scale: 2, null: false

      t.timestamps
    end
  end
end
