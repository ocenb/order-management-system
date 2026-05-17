class SendOrderCompletedEmailJob < ApplicationJob
  queue_as :mailers

  def perform(order_id)
    order = Order.find(order_id)
    return unless order.completed?

    order.with_lock do
      next if order.completed_email_sent_at.present?

      OrderMailer.with(order:).completed_email.deliver_now
      order.update!(completed_email_sent_at: Time.current)
    end
  end
end
