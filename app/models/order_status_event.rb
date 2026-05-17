class OrderStatusEvent < ApplicationRecord
  belongs_to :order

  validates :to_status, presence: true
end
