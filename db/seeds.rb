# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end

users = [
  { email: "admin@example.com", role: :admin },
  { email: "manager@example.com", role: :manager },
  { email: "operator@example.com", role: :operator }
]

users.each do |attrs|
  user = User.find_or_initialize_by(email: attrs[:email])
  user.password = "Password1!" if user.new_record?
  user.role = attrs[:role]
  user.save!
end

raw_token = "secret-token"
ApiToken.find_or_create_by!(name: "local-dev") do |token|
  token.token_digest = ApiToken.digest(raw_token)
  token.active = true
end
