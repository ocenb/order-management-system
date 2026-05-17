require "rails_helper"

RSpec.describe "Sidekiq dashboard access", type: :request do
  let(:operator) { User.create!(email: "sidekiq-operator@example.com", password: "Password1!", role: :operator) }
  let(:admin) { User.create!(email: "sidekiq-admin@example.com", password: "Password1!", role: :admin) }

  it "denies non-admin users" do
    sign_in operator
    get "/sidekiq"

    expect(response).to have_http_status(:not_found)
  end

  it "allows admin users" do
    sign_in admin
    get "/sidekiq"

    expect(response).to have_http_status(:ok)
  end
end
