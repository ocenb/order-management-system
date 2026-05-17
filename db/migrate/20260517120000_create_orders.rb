class CreateOrders < ActiveRecord::Migration[8.1]
  def change
    create_table :orders do |t|
      t.datetime :deleted_at
      t.string :source, null: false
      t.string :external_id, null: false
      t.string :status, null: false, default: "pending"
      t.string :customer_email, null: false
      t.string :customer_name, null: false
      t.text :delivery_address, null: false
      t.decimal :total_amount, precision: 12, scale: 2, null: false
      t.string :currency, null: false, default: "USD"
      t.text :error_message
      t.text :cancel_reason

      t.timestamps
    end

    add_index :orders, %i[source external_id], unique: true
    add_index :orders, :status
    add_index :orders, :deleted_at
  end
end
