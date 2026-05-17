require "rails_helper"

RSpec.describe "Api::V1::Orders", type: :request do
  let(:raw_token) { "secret-token" }
  let!(:api_token) { ApiToken.create!(name: "default", token_digest: ApiToken.digest(raw_token), active: true) }
  let(:headers) { { "Authorization" => "Bearer #{raw_token}" } }

  describe "POST /api/v1/orders" do
    let(:payload) do
      {
        order: {
          source: "shop",
          external_id: "ext-100",
          customer_email: "john@example.com",
          customer_name: "John",
          delivery_address: "Main st 1",
          total_amount: "199.90",
          currency: "USD",
          items: [
            { sku: "SKU-1", name: "Item 1", quantity: 2, price: "99.95" }
          ]
        }
      }
    end

    it "creates order and returns 201" do
      post "/api/v1/orders", params: payload, headers:, as: :json

      expect(response).to have_http_status(:created)
      expect(JSON.parse(response.body)["status"]).to eq("pending")
      expect(Order.count).to eq(1)
    end

    it "is idempotent and returns 200 for duplicate source/external_id" do
      post "/api/v1/orders", params: payload, headers:, as: :json
      post "/api/v1/orders", params: payload, headers:, as: :json

      expect(response).to have_http_status(:ok)
      expect(Order.count).to eq(1)
    end

    it "returns 401 without bearer token" do
      post "/api/v1/orders", params: payload, as: :json

      expect(response).to have_http_status(:unauthorized)
    end
  end

  describe "GET /api/v1/orders/:id" do
    let!(:order) do
      Order.create!(
        source: "shop",
        external_id: "ext-101",
        customer_email: "john@example.com",
        customer_name: "John",
        delivery_address: "Main st 1",
        total_amount: 10,
        currency: "USD"
      )
    end

    it "returns order status" do
      get "/api/v1/orders/#{order.id}", headers:, as: :json

      expect(response).to have_http_status(:ok)
      body = JSON.parse(response.body)
      expect(body["order_id"]).to eq(order.id)
      expect(body["status"]).to eq("pending")
    end

    it "returns 401 without bearer token" do
      get "/api/v1/orders/#{order.id}", as: :json

      expect(response).to have_http_status(:unauthorized)
    end
  end
end
