require "rails_helper"

RSpec.describe "Order flow E2E", type: :request do
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

  let(:raw_token) { "e2e-secret-token" }
  let!(:api_token) { ApiToken.create!(name: "e2e", token_digest: ApiToken.digest(raw_token), active: true) }
  let(:api_headers) { { "Authorization" => "Bearer #{raw_token}" } }
  let(:manager) { User.create!(email: "e2e-manager@example.com", password: "Password1!", role: :manager) }

  it "creates, processes, sends email, and allows manager actions" do
    payload = {
      order: {
        source: "shop",
        external_id: "ext-e2e-1",
        customer_email: "buyer@example.com",
        customer_name: "Buyer",
        delivery_address: "Old address",
        total_amount: "50.00",
        currency: "USD",
        items: [{ sku: "SKU-1", name: "Item 1", quantity: 1, price: "50.00" }]
      }
    }

    perform_enqueued_jobs do
      post "/api/v1/orders", params: payload, headers: api_headers, as: :json
      expect(response).to have_http_status(:created)
    end

    order = Order.find(JSON.parse(response.body).fetch("order_id"))
    expect(order.reload.status).to eq("completed")
    expect(ActionMailer::Base.deliveries.size).to eq(1)

    sign_in manager
    patch admin_order_path(order), params: { order: { delivery_address: "New address" } }
    expect(response).to redirect_to(admin_order_path(order))
    expect(order.reload.delivery_address).to eq("New address")
  end
end
