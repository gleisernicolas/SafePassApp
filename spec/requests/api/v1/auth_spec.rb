require 'rails_helper'

RSpec.describe "Api::V1::Auth", type: :request do
  describe "POST /api/v1/auth" do
    let(:user) { create(:user, email: "test@example.com", password: "password123") }

    context "with valid credentials" do
      before do
        post api_v1_auth_path, params: { email: user.email, password: "password123" }
      end

      it "returns success status" do
        expect(response).to have_http_status(:ok)
      end

      it "returns a token" do
        json = JSON.parse(response.body)
        expect(json["token"]).to be_present
      end

      it "returns a valid JWT token" do
        json = JSON.parse(response.body)
        decoded = JsonWebToken.decode(json["token"])
        expect(decoded["sub"]).to eq(user.id)
      end

      it "returns JSON content type" do
        expect(response.media_type).to eq("application/json")
      end
    end

    context "with invalid email" do
      before do
        post api_v1_auth_path, params: { email: "wrong@example.com", password: "password123" }
      end

      it "returns unauthorized status" do
        expect(response).to have_http_status(:unauthorized)
      end

      it "returns error message" do
        json = JSON.parse(response.body)
        expect(json["errors"]).to include("Invalid Email or Password")
      end
    end

    context "with invalid password" do
      before do
        post api_v1_auth_path, params: { email: user.email, password: "wrongpassword" }
      end

      it "returns unauthorized status" do
        expect(response).to have_http_status(:unauthorized)
      end

      it "returns error message" do
        json = JSON.parse(response.body)
        expect(json["errors"]).to include("Invalid Email or Password")
      end
    end

    context "with missing parameters" do
      it "returns unauthorized when email is missing" do
        post api_v1_auth_path, params: { password: "password123" }
        expect(response).to have_http_status(:unauthorized)
      end

      it "returns unauthorized when password is missing" do
        post api_v1_auth_path, params: { email: user.email }
        expect(response).to have_http_status(:unauthorized)
      end

      it "returns unauthorized when both are missing" do
        post api_v1_auth_path, params: {}
        expect(response).to have_http_status(:unauthorized)
      end
    end

    context "token expiration" do
      it "generates token with expiration" do
        post api_v1_auth_path, params: { email: user.email, password: "password123" }
        json = JSON.parse(response.body)
        decoded = JsonWebToken.decode(json["token"])
        expect(decoded["exp"]).to be_present
        expect(decoded["exp"]).to be > Time.now.to_i
      end
    end
  end
end
