require "rails_helper"

RSpec.describe Orders::CreateFromApi do
  include ActiveJob::TestHelper

  around do |example|
    original_adapter = ActiveJob::Base.queue_adapter
    ActiveJob::Base.queue_adapter = :test
    clear_enqueued_jobs
    example.run
    clear_enqueued_jobs
    ActiveJob::Base.queue_adapter = original_adapter
  end

  let(:attributes) do
    {
      source: "shop",
      external_id: "ext-300",
      customer_email: "john@example.com",
      customer_name: "John",
      delivery_address: "Main st 1",
      total_amount: "120.00",
      currency: "USD",
      items: [
        { sku: "SKU-1", name: "Item 1", quantity: 1, price: "120.00" }
      ]
    }
  end

  it "enqueues ProcessOrderJob for newly created order" do
    expect do
      described_class.call(attributes)
    end.to have_enqueued_job(ProcessOrderJob)
  end
end
