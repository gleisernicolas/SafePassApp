require 'rails_helper'

RSpec.describe "Pages", type: :request do
  describe "GET /home" do
    it "returns successful response" do
      get home_path
      expect(response).to be_successful
    end

    it "does not require authentication" do
      get home_path
      expect(response).not_to redirect_to(new_user_session_path)
    end
  end

  describe "GET /about" do
    it "returns successful response" do
      get about_path
      expect(response).to be_successful
    end

    it "does not require authentication" do
      get about_path
      expect(response).not_to redirect_to(new_user_session_path)
    end
  end
end
