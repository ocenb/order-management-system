require "swagger_helper"

RSpec.describe "API V1 Orders", type: :request do
  let(:raw_token) { "swagger-secret-token" }
  let!(:api_token) { ApiToken.create!(name: "swagger", token_digest: ApiToken.digest(raw_token), active: true) }
  let(:Authorization) { "Bearer #{raw_token}" }

  path "/api/v1/orders" do
    post "Create order" do
      tags "Orders"
      consumes "application/json"
      produces "application/json"
      security [ bearerAuth: [] ]

      parameter name: :order_payload, in: :body, schema: {
        type: :object,
        properties: {
          order: {
            type: :object,
            required: %w[source external_id customer_email customer_name delivery_address total_amount currency items],
            properties: {
              source: { type: :string, example: "shop" },
              external_id: { type: :string, example: "ext-100" },
              customer_email: { type: :string, format: :email, example: "john@example.com" },
              customer_name: { type: :string, example: "John" },
              delivery_address: { type: :string, example: "Main st 1" },
              total_amount: { type: :string, example: "199.90" },
              currency: { type: :string, example: "USD" },
              items: {
                type: :array,
                items: {
                  type: :object,
                  required: %w[sku name quantity price],
                  properties: {
                    sku: { type: :string, example: "SKU-1" },
                    name: { type: :string, example: "Item 1" },
                    quantity: { type: :integer, example: 2 },
                    price: { type: :string, example: "99.95" }
                  }
                }
              }
            }
          }
        },
        required: [ "order" ]
      }

      response "201", "order created" do
        let(:order_payload) do
          {
            order: {
              source: "shop",
              external_id: "ext-swagger-1",
              customer_email: "john@example.com",
              customer_name: "John",
              delivery_address: "Main st 1",
              total_amount: "199.90",
              currency: "USD",
              items: [ { sku: "SKU-1", name: "Item 1", quantity: 2, price: "99.95" } ]
            }
          }
        end

        run_test!
      end

      response "401", "unauthorized" do
        let(:Authorization) { nil }
        let(:order_payload) do
          {
            order: {
              source: "shop",
              external_id: "ext-swagger-unauth",
              customer_email: "john@example.com",
              customer_name: "John",
              delivery_address: "Main st 1",
              total_amount: "10.00",
              currency: "USD",
              items: [ { sku: "SKU-1", name: "Item 1", quantity: 1, price: "10.00" } ]
            }
          }
        end

        run_test!
      end
    end
  end

  path "/api/v1/orders/{id}" do
    get "Show order status" do
      tags "Orders"
      produces "application/json"
      security [ bearerAuth: [] ]
      parameter name: :id, in: :path, type: :integer

      response "200", "order found" do
        let!(:order) do
          Order.create!(
            source: "shop",
            external_id: "ext-swagger-2",
            customer_email: "john@example.com",
            customer_name: "John",
            delivery_address: "Main st 1",
            total_amount: 10,
            currency: "USD"
          )
        end
        let(:id) { order.id }

        run_test!
      end

      response "401", "unauthorized" do
        let!(:order) do
          Order.create!(
            source: "shop",
            external_id: "ext-swagger-3",
            customer_email: "john@example.com",
            customer_name: "John",
            delivery_address: "Main st 1",
            total_amount: 10,
            currency: "USD"
          )
        end
        let(:id) { order.id }
        let(:Authorization) { nil }

        run_test!
      end
    end
  end
end
