require "rails_helper"

RSpec.describe "Admin::Users", type: :request do
  let(:operator) { User.create!(email: "operator2@example.com", password: "Password1!", role: :operator) }
  let(:admin) { User.create!(email: "admin2@example.com", password: "Password1!", role: :admin) }
  let!(:target_user) { User.create!(email: "target@example.com", password: "Password1!", role: :operator) }

  it "forbids non-admin users" do
    sign_in operator
    get admin_users_path
    expect(response).to redirect_to(root_path)
  end

  it "allows admin to list users" do
    sign_in admin
    get admin_users_path
    expect(response).to have_http_status(:ok)
  end

  it "allows admin to update role" do
    sign_in admin
    patch admin_user_path(target_user), params: { user: { role: "manager" } }
    expect(response).to redirect_to(admin_users_path)
    expect(target_user.reload.role).to eq("manager")
  end
end
