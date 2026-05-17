class Order < ApplicationRecord
  class InvalidStatusTransition < StandardError; end

  STATUSES = {
    pending: "pending",
    processing: "processing",
    completed: "completed",
    failed: "failed",
    cancelled: "cancelled"
  }.freeze

  ALLOWED_STATUS_TRANSITIONS = {
    pending: %i[processing cancelled],
    processing: %i[completed failed cancelled],
    failed: %i[processing],
    completed: [],
    cancelled: []
  }.freeze

  has_many :order_items, dependent: :destroy
  has_many :order_status_events, dependent: :destroy

  enum :status, STATUSES, validate: true

  accepts_nested_attributes_for :order_items

  validates :source, :external_id, :customer_email, :customer_name, :delivery_address, :currency, presence: true
  validates :total_amount, numericality: { greater_than: 0 }
  validates :source, uniqueness: { scope: :external_id }

  def can_transition_to?(target_status)
    target = target_status.to_sym
    ALLOWED_STATUS_TRANSITIONS.fetch(status.to_sym, []).include?(target)
  end

  def transition_to!(target_status, changed_by_user_id: nil, reason: nil)
    target = target_status.to_sym

    unless can_transition_to?(target)
      raise InvalidStatusTransition, "Transition #{status} -> #{target} is not allowed"
    end

    previous_status = status

    transaction do
      update!(status: target)
      order_status_events.create!(
        from_status: previous_status,
        to_status: target,
        changed_by_user_id: changed_by_user_id,
        reason: reason
      )
    end
  end

  def enqueue_processing!
    ProcessOrderJob.perform_later(id)
  end

  def retry_processing!
    raise InvalidStatusTransition, "Retry is allowed only for failed orders" unless failed?

    enqueue_processing!
  end
end
