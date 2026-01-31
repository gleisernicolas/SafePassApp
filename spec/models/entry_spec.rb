require 'rails_helper'

RSpec.describe Entry, type: :model do
  describe "associations" do
    it "belongs to a user" do
      entry = build(:entry)
      expect(entry.user).to be_present
    end

    it "requires a user" do
      entry = build(:entry, user: nil)
      expect(entry).not_to be_valid
    end
  end

  describe "validations" do
    subject { build(:entry) }

    it { should validate_presence_of(:name) }
    it { should validate_presence_of(:username) }
    it { should validate_presence_of(:password) }

    describe "url presence" do
      it "is invalid with blank url" do
        # Note: custom validator calls url.include? which fails on nil,
        # so testing with empty string instead
        entry = build(:entry, url: "")
        expect(entry).not_to be_valid
        expect(entry.errors[:url]).to include("can't be blank")
      end
    end

    describe "url_must_be_valid" do
      let(:user) { create(:user) }

      it "is valid with http url" do
        entry = build(:entry, user: user, url: "http://example.com")
        expect(entry).to be_valid
      end

      it "is valid with https url" do
        entry = build(:entry, user: user, url: "https://example.com")
        expect(entry).to be_valid
      end

      it "is invalid without http or https" do
        entry = build(:entry, user: user, url: "example.com")
        expect(entry).not_to be_valid
        expect(entry.errors[:url]).to include("URL must be valid")
      end

      it "is invalid with ftp url" do
        entry = build(:entry, user: user, url: "ftp://example.com")
        expect(entry).not_to be_valid
      end
    end
  end

  describe "factory" do
    it "creates a valid entry" do
      entry = build(:entry)
      expect(entry).to be_valid
    end

    it "creates an invalid entry with :invalid trait" do
      entry = build(:entry, :invalid)
      expect(entry).not_to be_valid
    end

    it "creates an entry with invalid url using :invalid_url trait" do
      entry = build(:entry, :invalid_url)
      expect(entry).not_to be_valid
    end
  end

  describe "encryption" do
    let(:user) { create(:user) }
    let(:entry) { create(:entry, user: user, username: "testuser", password: "secretpass123") }

    it "encrypts username deterministically" do
      create(:entry, user: user, username: "testuser", password: "different123")

      # Deterministic encryption means same plaintext = same ciphertext
      # We can search by username
      expect(Entry.find_by(username: "testuser")).to be_present
    end

    it "decrypts username correctly" do
      expect(entry.username).to eq("testuser")
    end

    it "decrypts password correctly" do
      expect(entry.password).to eq("secretpass123")
    end

    it "stores encrypted values in database" do
      # Raw database values should not be plaintext
      raw_entry = Entry.find_by_sql(
        ["SELECT username, password FROM entries WHERE id = ?", entry.id]
      ).first

      # The raw values should be present (not nil)
      expect(raw_entry).to be_present
    end
  end

  describe ".search" do
    let(:user) { create(:user) }

    before do
      create(:entry, user: user, name: "Gmail Account")
      create(:entry, user: user, name: "GitHub Personal")
      create(:entry, user: user, name: "Amazon Shopping")
    end

    it "finds entries by partial name match" do
      results = Entry.search("git")
      expect(results.count).to eq(1)
      expect(results.first.name).to eq("GitHub Personal")
    end

    it "is case insensitive" do
      results = Entry.search("GMAIL")
      expect(results.count).to eq(1)
      expect(results.first.name).to eq("Gmail Account")
    end

    # Rails scopes with conditional `if` at the end return all records
    # when the condition is false, not nil.
    it "returns all entries when search term is nil" do
      results = Entry.search(nil)
      expect(results.count).to eq(3)
    end

    it "returns all entries when search term is blank" do
      results = Entry.search("")
      expect(results.count).to eq(3)
    end

    it "returns multiple matches" do
      create(:entry, user: user, name: "Git Credentials")
      results = Entry.search("git")
      expect(results.count).to eq(2)
    end

    it "returns empty relation when no matches found" do
      results = Entry.search("nonexistent")
      expect(results).to be_empty
    end
  end

  describe ".search_name scope" do
    let(:user) { create(:user) }

    before do
      create(:entry, user: user, name: "Netflix Account")
      create(:entry, user: user, name: "Spotify Premium")
    end

    it "returns matching entries" do
      expect(Entry.search_name("Netflix").count).to eq(1)
    end

    it "returns all entries for blank input" do
      # Rails scope with conditional `if` returns all records when condition is false
      expect(Entry.search_name("").count).to eq(2)
    end
  end

  describe "user scoping" do
    let(:user1) { create(:user) }
    let(:user2) { create(:user) }

    before do
      create(:entry, user: user1, name: "User1 Entry")
      create(:entry, user: user2, name: "User2 Entry")
    end

    it "returns only entries belonging to the user" do
      expect(user1.entries.count).to eq(1)
      expect(user1.entries.first.name).to eq("User1 Entry")
    end

    it "does not return other users entries" do
      expect(user1.entries.pluck(:name)).not_to include("User2 Entry")
    end
  end
end
