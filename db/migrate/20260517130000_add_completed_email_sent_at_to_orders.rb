class AddCompletedEmailSentAtToOrders < ActiveRecord::Migration[8.1]
  def change
    add_column :orders, :completed_email_sent_at, :datetime
    add_index :orders, :completed_email_sent_at
  end
end
