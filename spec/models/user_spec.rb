require 'rails_helper'

RSpec.describe User, type: :model do
  describe "associations" do
    it { should have_many(:entries).dependent(:destroy) }
  end

  describe "validations" do
    subject { build(:user) }

    it { should validate_presence_of(:email) }
    it { should validate_uniqueness_of(:email).case_insensitive }
    it { should validate_presence_of(:password) }
  end

  describe "factory" do
    it "creates a valid user" do
      user = build(:user)
      expect(user).to be_valid
    end

    it "creates a user with entries using the trait" do
      user = create(:user, :with_entries, entries_count: 5)
      expect(user.entries.count).to eq(5)
    end
  end

  describe "Devise modules" do
    it "includes database_authenticatable" do
      expect(User.devise_modules).to include(:database_authenticatable)
    end

    it "includes registerable" do
      expect(User.devise_modules).to include(:registerable)
    end

    it "includes recoverable" do
      expect(User.devise_modules).to include(:recoverable)
    end

    it "includes rememberable" do
      expect(User.devise_modules).to include(:rememberable)
    end

    it "includes validatable" do
      expect(User.devise_modules).to include(:validatable)
    end
  end

  describe "dependent destroy" do
    it "destroys associated entries when user is destroyed" do
      user = create(:user, :with_entries, entries_count: 3)
      entries = user.entries.to_a

      expect { user.destroy }.to change(Entry, :count).by(-3)
      entries.each do |entry|
        expect(Entry.exists?(entry.id)).to be false
      end
    end
  end

  describe "authentication" do
    it "authenticates with correct password" do
      user = User.create!(
        email: "auth@test.com",
        password: "securepassword123",
        password_confirmation: "securepassword123"
      )
      expect(user.valid_password?("securepassword123")).to be true
    end

    it "does not authenticate with incorrect password" do
      user = User.create!(
        email: "auth2@test.com",
        password: "securepassword123",
        password_confirmation: "securepassword123"
      )
      expect(user.valid_password?("wrongpassword")).to be false
    end
  end
end
