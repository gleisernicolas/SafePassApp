class Entry < ApplicationRecord
  belongs_to :user

  validates :name, :username, :password, :url, presence: true

  validate :url_must_be_valid

  encrypts :username, deterministic: true
  encrypts :password

  scope :search_name, ->(name) { where("name ILIKE ?", "%#{name}%") if name.present? }

  def self.search(name)
    search_name(name)
  end

  private

  def url_must_be_valid
    unless url.include?("http") || url.include?("https")
      errors.add(:url, "URL must be valid")
    end
  end
end
