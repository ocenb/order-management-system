require "rails_helper"

RSpec.describe Order, type: :model do
  let(:order) do
    described_class.create!(
      source: "shop",
      external_id: "ext-1",
      customer_email: "john@example.com",
      customer_name: "John",
      delivery_address: "Main st 1",
      total_amount: 100,
      currency: "USD"
    )
  end

  it "allows transition pending -> processing" do
    expect { order.transition_to!(:processing) }
      .to change { order.reload.status }.from("pending").to("processing")
  end

  it "rejects transition pending -> completed" do
    expect { order.transition_to!(:completed) }
      .to raise_error(Order::InvalidStatusTransition)
  end
end
