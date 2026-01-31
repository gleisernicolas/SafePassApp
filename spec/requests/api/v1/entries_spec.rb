require 'rails_helper'

RSpec.describe "Api::V1::Entries", type: :request do
  let(:user) { create(:user) }
  let(:other_user) { create(:user) }
  let(:token) { JsonWebToken.encode(sub: user.id) }
  let(:auth_headers) { { "Authorization" => "Bearer #{token}" } }

  describe "GET /api/v1/entries" do
    context "with valid token" do
      before do
        create(:entry, user: user, name: "Zebra Entry")
        create(:entry, user: user, name: "Alpha Entry")
        create(:entry, user: user, name: "Middle Entry")
      end

      it "returns success status" do
        get api_v1_entries_path, headers: auth_headers
        expect(response).to have_http_status(:ok)
      end

      it "returns user's entries as JSON" do
        get api_v1_entries_path, headers: auth_headers
        json = JSON.parse(response.body)
        expect(json.length).to eq(3)
      end

      it "returns entries ordered by name" do
        get api_v1_entries_path, headers: auth_headers
        json = JSON.parse(response.body)
        names = json.map { |e| e["name"] }
        expect(names).to eq(["Alpha Entry", "Middle Entry", "Zebra Entry"])
      end

      it "returns entry attributes" do
        get api_v1_entries_path, headers: auth_headers
        json = JSON.parse(response.body)
        entry = json.first
        expect(entry).to have_key("id")
        expect(entry).to have_key("name")
        expect(entry).to have_key("username")
        expect(entry).to have_key("password")
        expect(entry).to have_key("url")
      end

      it "returns JSON content type" do
        get api_v1_entries_path, headers: auth_headers
        expect(response.media_type).to eq("application/json")
      end
    end

    context "user scoping" do
      before do
        create(:entry, user: user, name: "My Entry")
        create(:entry, user: other_user, name: "Other User Entry")
      end

      it "only returns current user's entries" do
        get api_v1_entries_path, headers: auth_headers
        json = JSON.parse(response.body)
        names = json.map { |e| e["name"] }
        expect(names).to include("My Entry")
        expect(names).not_to include("Other User Entry")
      end

      it "returns correct count for user" do
        get api_v1_entries_path, headers: auth_headers
        json = JSON.parse(response.body)
        expect(json.length).to eq(1)
      end
    end

    context "without token" do
      it "returns unauthorized status" do
        get api_v1_entries_path
        expect(response).to have_http_status(:unauthorized)
      end

      it "returns error message" do
        get api_v1_entries_path
        json = JSON.parse(response.body)
        expect(json["errors"]).to be_present
      end
    end

    context "with invalid token" do
      let(:invalid_headers) { { "Authorization" => "Bearer invalid.token.here" } }

      it "returns unauthorized status" do
        get api_v1_entries_path, headers: invalid_headers
        expect(response).to have_http_status(:unauthorized)
      end

      it "returns error message" do
        get api_v1_entries_path, headers: invalid_headers
        json = JSON.parse(response.body)
        expect(json["errors"]).to include("Invalid auth token.")
      end
    end

    context "with expired token" do
      let(:expired_token) { JsonWebToken.encode({ sub: user.id }, 1.hour.ago.to_i) }
      let(:expired_headers) { { "Authorization" => "Bearer #{expired_token}" } }

      it "returns unauthorized status" do
        get api_v1_entries_path, headers: expired_headers
        expect(response).to have_http_status(:unauthorized)
      end

      it "returns expiration error message" do
        get api_v1_entries_path, headers: expired_headers
        json = JSON.parse(response.body)
        expect(json["errors"]).to include("Auth token has expired.")
      end
    end

    context "with malformed authorization header" do
      # Note: The auth_token method splits by space and takes the last element,
      # so a token without "Bearer " prefix still works if the token itself is valid.
      # This test verifies that completely invalid tokens fail.
      it "returns unauthorized for garbage token without Bearer" do
        get api_v1_entries_path, headers: { "Authorization" => "not-a-valid-token" }
        expect(response).to have_http_status(:unauthorized)
      end

      it "returns unauthorized for empty authorization" do
        get api_v1_entries_path, headers: { "Authorization" => "" }
        expect(response).to have_http_status(:unauthorized)
      end
    end

    context "when user has no entries" do
      it "returns empty array" do
        get api_v1_entries_path, headers: auth_headers
        json = JSON.parse(response.body)
        expect(json).to eq([])
      end

      it "returns success status" do
        get api_v1_entries_path, headers: auth_headers
        expect(response).to have_http_status(:ok)
      end
    end
  end
end
