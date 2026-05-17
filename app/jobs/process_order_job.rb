class ProcessOrderJob < ApplicationJob
  queue_as :default

  def perform(order_id)
    order = Order.find(order_id)
    return if order.completed? || order.cancelled?

    order.transition_to!(:processing) if order.pending? || order.failed?

    Warehouse::StubClient.process!(order)
    order.transition_to!(:completed)
  rescue Warehouse::StubClient::ProcessingError => e
    order&.transition_to!(:failed, reason: e.message) if order&.processing?
    order&.update!(error_message: e.message)
  end
end
