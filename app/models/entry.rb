class Entry < ApplicationRecord
  belongs_to :user

  validates :name, :username, :password, :url, presence: true

  validate :url_must_be_valid

  encrypts :username, deterministic: true
  encrypts :password

  private

  def url_must_be_valid
    unless url.include?("http") || url.include?("https")
      errors.add(:url, "URL must be valid")
    end
  end
end
