require "rails_helper"
require "securerandom"

RSpec.describe "Admin::Orders", type: :request do
  let(:order) do
    Order.create!(
      source: "shop",
      external_id: "ext-admin-1",
      customer_email: "john@example.com",
      customer_name: "John",
      delivery_address: "Main st 1",
      total_amount: 100,
      currency: "USD"
    )
  end

  let(:operator) { User.create!(email: "operator-#{SecureRandom.hex(4)}@example.com", password: "Password1!", role: :operator) }
  let(:manager) { User.create!(email: "manager-#{SecureRandom.hex(4)}@example.com", password: "Password1!", role: :manager) }
  let(:admin) { User.create!(email: "admin-#{SecureRandom.hex(4)}@example.com", password: "Password1!", role: :admin) }

  it "requires authentication" do
    get admin_orders_path
    expect(response).to redirect_to(new_user_session_path)
  end

  it "allows operator to view orders list" do
    sign_in operator
    get admin_orders_path
    expect(response).to have_http_status(:ok)
  end

  it "forbids operator from cancel" do
    sign_in operator
    patch cancel_admin_order_path(order)
    expect(response).to redirect_to(root_path)
  end

  it "allows manager to cancel" do
    sign_in manager
    patch cancel_admin_order_path(order)
    expect(response).to redirect_to(admin_order_path(order))
    expect(order.reload.status).to eq("cancelled")
  end

  it "allows admin to soft delete" do
    sign_in admin
    delete admin_order_path(order)
    expect(response).to redirect_to(admin_orders_path)
    expect(order.reload.deleted_at).to be_present
  end
end
