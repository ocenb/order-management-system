require "rails_helper"

RSpec.describe "Admin role matrix E2E", type: :request do
  let!(:order) do
    Order.create!(
      source: "shop",
      external_id: "role-matrix-1",
      customer_email: "buyer@example.com",
      customer_name: "Buyer",
      delivery_address: "Role st",
      total_amount: 15,
      currency: "USD"
    )
  end

  let(:operator) { User.create!(email: "matrix-operator@example.com", password: "Password1!", role: :operator) }
  let(:manager) { User.create!(email: "matrix-manager@example.com", password: "Password1!", role: :manager) }
  let(:admin) { User.create!(email: "matrix-admin@example.com", password: "Password1!", role: :admin) }

  it "enforces role permissions across key admin actions" do
    sign_in operator
    patch cancel_admin_order_path(order)
    expect(response).to redirect_to(root_path)

    patch admin_order_path(order), params: { order: { status: "processing" } }
    expect(response).to redirect_to(admin_order_path(order))
    expect(order.reload.status).to eq("processing")

    sign_out operator
    sign_in manager
    patch cancel_admin_order_path(order)
    expect(response).to redirect_to(admin_order_path(order))
    expect(order.reload.status).to eq("cancelled")

    sign_out manager
    sign_in admin
    delete admin_order_path(order)
    expect(response).to redirect_to(admin_orders_path)
    expect(order.reload.deleted_at).to be_present
  end
end
