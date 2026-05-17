require "rails_helper"

RSpec.describe "Failed order retry E2E", type: :request do
  include ActiveJob::TestHelper

  around do |example|
    original_adapter = ActiveJob::Base.queue_adapter
    ActiveJob::Base.queue_adapter = :test
    clear_enqueued_jobs
    ActionMailer::Base.deliveries.clear
    example.run
    clear_enqueued_jobs
    ActiveJob::Base.queue_adapter = original_adapter
  end

  let(:raw_token) { "e2e-retry-token" }
  let!(:api_token) { ApiToken.create!(name: "e2e-retry", token_digest: ApiToken.digest(raw_token), active: true) }
  let(:api_headers) { { "Authorization" => "Bearer #{raw_token}" } }
  let(:manager) { User.create!(email: "retry-manager@example.com", password: "Password1!", role: :manager) }

  it "fails processing and can be retried by manager" do
    payload = {
      order: {
        source: "shop",
        external_id: "fail-e2e-1",
        customer_email: "buyer@example.com",
        customer_name: "Buyer",
        delivery_address: "Retry street",
        total_amount: "50.00",
        currency: "USD",
        items: [ { sku: "SKU-1", name: "Item 1", quantity: 1, price: "50.00" } ]
      }
    }

    perform_enqueued_jobs do
      post "/api/v1/orders", params: payload, headers: api_headers, as: :json
      expect(response).to have_http_status(:created)
    end

    order = Order.find(JSON.parse(response.body).fetch("order_id"))
    expect(order.reload.status).to eq("failed")
    expect(order.error_message).to eq("Warehouse validation failed")

    allow(Warehouse::StubClient).to receive(:process!).and_return(true)

    sign_in manager
    perform_enqueued_jobs do
      post retry_admin_order_path(order)
      expect(response).to redirect_to(admin_order_path(order))
    end

    expect(order.reload.status).to eq("completed")
    expect(ActionMailer::Base.deliveries.size).to eq(1)
  end
end
