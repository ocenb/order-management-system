class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable,
         :recoverable, :rememberable, :validatable

  ROLES = {
    operator: "operator",
    manager: "manager",
    admin: "admin"
  }.freeze

  enum :role, ROLES, validate: true
end
