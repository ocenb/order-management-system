require "rails_helper"

RSpec.describe User, type: :model do
  it "defaults role to operator" do
    user = described_class.create!(email: "new-user@example.com", password: "Password1!")

    expect(user.role).to eq("operator")
  end
end
