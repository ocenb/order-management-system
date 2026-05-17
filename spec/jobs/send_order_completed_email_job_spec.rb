require "rails_helper"

RSpec.describe SendOrderCompletedEmailJob, type: :job do
  let(:order) do
    Order.create!(
      source: "shop",
      external_id: "ext-500",
      customer_email: "john@example.com",
      customer_name: "John",
      delivery_address: "Main st 1",
      total_amount: 100,
      currency: "USD",
      status: :completed
    )
  end

  before { ActionMailer::Base.deliveries.clear }

  it "sends completed email and marks timestamp" do
    expect do
      described_class.perform_now(order.id)
    end.to change { ActionMailer::Base.deliveries.size }.by(1)

    expect(order.reload.completed_email_sent_at).to be_present
  end

  it "does not send duplicate email" do
    described_class.perform_now(order.id)

    expect do
      described_class.perform_now(order.id)
    end.not_to change { ActionMailer::Base.deliveries.size }
  end
end
