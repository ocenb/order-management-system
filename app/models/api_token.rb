require "digest"

class ApiToken < ApplicationRecord
  validates :name, :token_digest, presence: true
  validates :token_digest, uniqueness: true

  scope :active, -> { where(active: true) }

  def self.digest(token)
    Digest::SHA256.hexdigest(token.to_s)
  end
end
