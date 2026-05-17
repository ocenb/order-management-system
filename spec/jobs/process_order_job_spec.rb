require "rails_helper"

RSpec.describe ProcessOrderJob, type: :job do
  let(:order) do
    Order.create!(
      source: "shop",
      external_id: external_id,
      customer_email: "john@example.com",
      customer_name: "John",
      delivery_address: "Main st 1",
      total_amount: 100,
      currency: "USD"
    )
  end

  let(:external_id) { "ext-200" }

  it "moves order to completed on success" do
    described_class.perform_now(order.id)

    expect(order.reload.status).to eq("completed")
    expect(order.order_status_events.pluck(:to_status)).to include("processing", "completed")
  end

  context "when warehouse processing fails" do
    let(:external_id) { "fail-200" }

    it "moves order to failed and stores error" do
      described_class.perform_now(order.id)

      expect(order.reload.status).to eq("failed")
      expect(order.error_message).to eq("Warehouse validation failed")
      expect(order.order_status_events.pluck(:to_status)).to include("processing", "failed")
    end
  end
end
