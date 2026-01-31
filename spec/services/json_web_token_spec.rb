require 'rails_helper'

RSpec.describe JsonWebToken do
  let(:user) { create(:user) }
  let(:payload) { { sub: user.id } }

  describe ".encode" do
    it "returns a JWT token string" do
      token = described_class.encode(payload)
      expect(token).to be_a(String)
      expect(token.split(".").length).to eq(3) # JWT format: header.payload.signature
    end

    it "encodes the payload" do
      token = described_class.encode(payload)
      decoded = described_class.decode(token)
      expect(decoded["sub"]).to eq(user.id)
    end

    it "sets default expiration to 30 minutes" do
      token = described_class.encode(payload)
      decoded = described_class.decode(token)
      expected_exp = 30.minutes.from_now.to_i

      # Allow 5 second variance for test execution time
      expect(decoded["exp"]).to be_within(5).of(expected_exp)
    end

    it "allows custom expiration" do
      custom_exp = 1.hour.from_now.to_i
      token = described_class.encode(payload, custom_exp)
      decoded = described_class.decode(token)
      expect(decoded["exp"]).to eq(custom_exp)
    end

    it "includes all payload data" do
      extended_payload = { sub: user.id, email: user.email, role: "admin" }
      token = described_class.encode(extended_payload)
      decoded = described_class.decode(token)
      expect(decoded["sub"]).to eq(user.id)
      expect(decoded["email"]).to eq(user.email)
      expect(decoded["role"]).to eq("admin")
    end
  end

  describe ".decode" do
    context "with valid token" do
      let(:token) { described_class.encode(payload) }

      it "returns the decoded payload" do
        decoded = described_class.decode(token)
        expect(decoded).to be_a(Hash)
      end

      it "includes the subject (sub)" do
        decoded = described_class.decode(token)
        expect(decoded["sub"]).to eq(user.id)
      end

      it "includes the expiration (exp)" do
        decoded = described_class.decode(token)
        expect(decoded["exp"]).to be_present
      end
    end

    context "with expired token" do
      let(:expired_token) { described_class.encode(payload, 1.hour.ago.to_i) }

      it "returns error hash" do
        decoded = described_class.decode(expired_token)
        expect(decoded).to have_key(:error)
      end

      it "returns expiration error message" do
        decoded = described_class.decode(expired_token)
        expect(decoded[:error]).to eq("Auth token has expired.")
      end
    end

    context "with invalid token" do
      it "returns error for malformed token" do
        decoded = described_class.decode("invalid.token.string")
        expect(decoded[:error]).to eq("Invalid auth token.")
      end

      it "returns error for empty string" do
        decoded = described_class.decode("")
        expect(decoded[:error]).to eq("Invalid auth token.")
      end

      it "returns error for nil" do
        decoded = described_class.decode(nil)
        expect(decoded[:error]).to eq("Invalid auth token.")
      end

      it "returns error for tampered token" do
        token = described_class.encode(payload)
        tampered_token = token[0..-5] + "xxxx"
        decoded = described_class.decode(tampered_token)
        expect(decoded[:error]).to eq("Invalid auth token.")
      end
    end

    context "with token signed by different secret" do
      it "returns error" do
        # Create token with different secret
        other_token = JWT.encode(payload, "different_secret")
        decoded = described_class.decode(other_token)
        expect(decoded[:error]).to eq("Invalid auth token.")
      end
    end
  end

  describe "SECRET_KEY" do
    it "uses rails credentials secret_key_base" do
      expect(JsonWebToken::SECRET_KEY).to eq(Rails.application.credentials.dig(:secret_key_base))
    end
  end

  describe "round trip" do
    it "encodes and decodes correctly" do
      original_payload = { sub: user.id, custom: "data" }
      token = described_class.encode(original_payload)
      decoded = described_class.decode(token)

      expect(decoded["sub"]).to eq(original_payload[:sub])
      expect(decoded["custom"]).to eq(original_payload[:custom])
    end
  end
end
