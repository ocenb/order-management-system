class CreateOrderStatusEvents < ActiveRecord::Migration[8.1]
  def change
    create_table :order_status_events do |t|
      t.references :order, null: false, foreign_key: true
      t.string :from_status
      t.string :to_status, null: false
      t.bigint :changed_by_user_id
      t.text :reason
      t.datetime :created_at, null: false, default: -> { "CURRENT_TIMESTAMP" }
    end

    add_index :order_status_events, :changed_by_user_id
  end
end
