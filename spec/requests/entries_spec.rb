require 'rails_helper'

RSpec.describe "Entries", type: :request do
  let(:user) { create(:user) }
  let(:other_user) { create(:user) }
  let(:entry) { create(:entry, user: user) }
  let(:other_entry) { create(:entry, user: other_user) }

  describe "authentication" do
    it "redirects unauthenticated users from index" do
      get entries_path
      expect(response).to redirect_to(new_user_session_path)
    end

    it "redirects unauthenticated users from new" do
      get new_entry_path
      expect(response).to redirect_to(new_user_session_path)
    end

    it "redirects unauthenticated users from create" do
      post entries_path, params: { entry: attributes_for(:entry) }
      expect(response).to redirect_to(new_user_session_path)
    end

    it "redirects unauthenticated users from show" do
      get entry_path(entry)
      expect(response).to redirect_to(new_user_session_path)
    end

    it "redirects unauthenticated users from edit" do
      get edit_entry_path(entry)
      expect(response).to redirect_to(new_user_session_path)
    end

    it "redirects unauthenticated users from update" do
      patch entry_path(entry), params: { entry: { name: "Updated" } }
      expect(response).to redirect_to(new_user_session_path)
    end

    it "redirects unauthenticated users from destroy" do
      delete entry_path(entry)
      expect(response).to redirect_to(new_user_session_path)
    end
  end

  describe "GET /entries (index)" do
    before { sign_in user }

    it "returns successful response" do
      get entries_path
      expect(response).to be_successful
    end

    it "displays user's entries" do
      create(:entry, user: user, name: "My Password")
      get entries_path
      expect(response.body).to include("My Password")
    end

    it "does not display other users' entries" do
      create(:entry, user: other_user, name: "Other User Password")
      get entries_path
      expect(response.body).not_to include("Other User Password")
    end

    context "with search parameter" do
      before do
        create(:entry, user: user, name: "Gmail Account")
        create(:entry, user: user, name: "GitHub Personal")
        create(:entry, user: user, name: "Amazon Shopping")
      end

      it "filters entries by name" do
        get entries_path, params: { name: "git" }
        expect(response.body).to include("GitHub Personal")
      end

      it "returns turbo stream for single result" do
        get entries_path, params: { name: "Gmail" }, headers: { "Accept" => "text/vnd.turbo-stream.html" }
        expect(response.media_type).to eq("text/vnd.turbo-stream.html")
      end
    end
  end

  describe "GET /entries/new" do
    before { sign_in user }

    it "returns successful response" do
      get new_entry_path
      expect(response).to be_successful
    end

    it "renders the new template" do
      get new_entry_path
      expect(response.body).to include("form")
    end
  end

  describe "POST /entries (create)" do
    before { sign_in user }

    let(:valid_attributes) do
      {
        name: "New Entry",
        username: "newuser",
        password: "newpassword123",
        url: "https://example.com"
      }
    end

    let(:invalid_attributes) do
      {
        name: "",
        username: "newuser",
        password: "newpassword123",
        url: "https://example.com"
      }
    end

    context "with valid parameters" do
      it "creates a new entry" do
        expect {
          post entries_path, params: { entry: valid_attributes }
        }.to change(Entry, :count).by(1)
      end

      it "associates entry with current user" do
        post entries_path, params: { entry: valid_attributes }
        expect(Entry.last.user).to eq(user)
      end

      it "redirects to root path" do
        post entries_path, params: { entry: valid_attributes }
        expect(response).to redirect_to(root_path)
      end

      it "sets flash notice with entry name" do
        post entries_path, params: { entry: valid_attributes }
        expect(flash[:notice]).to include("New Entry")
      end

      it "responds to turbo stream" do
        post entries_path,
             params: { entry: valid_attributes },
             headers: { "Accept" => "text/vnd.turbo-stream.html" }
        expect(response.media_type).to eq("text/vnd.turbo-stream.html")
      end
    end

    context "with invalid parameters" do
      it "does not create a new entry" do
        expect {
          post entries_path, params: { entry: invalid_attributes }
        }.not_to change(Entry, :count)
      end

      it "returns unprocessable entity status" do
        post entries_path, params: { entry: invalid_attributes }
        expect(response).to have_http_status(:unprocessable_entity)
      end

      it "renders the new template" do
        post entries_path, params: { entry: invalid_attributes }
        expect(response.body).to include("form")
      end
    end

    context "with invalid URL" do
      let(:invalid_url_attributes) do
        {
          name: "Test",
          username: "test",
          password: "test123",
          url: "invalid-url.com"
        }
      end

      it "does not create entry" do
        expect {
          post entries_path, params: { entry: invalid_url_attributes }
        }.not_to change(Entry, :count)
      end

      it "returns unprocessable entity status" do
        post entries_path, params: { entry: invalid_url_attributes }
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end

  describe "GET /entries/:id (show)" do
    before { sign_in user }

    it "returns successful response for user's entry" do
      get entry_path(entry)
      expect(response).to be_successful
    end

    it "displays entry details" do
      get entry_path(entry)
      expect(response.body).to include(entry.name)
    end

    it "returns 404 when accessing other user's entry" do
      get entry_path(other_entry)
      expect(response).to have_http_status(:not_found)
    end
  end

  describe "GET /entries/:id/edit" do
    before { sign_in user }

    it "returns successful response for user's entry" do
      get edit_entry_path(entry)
      expect(response).to be_successful
    end

    it "renders the edit form" do
      get edit_entry_path(entry)
      expect(response.body).to include("form")
    end

    it "returns 404 when accessing other user's entry" do
      get edit_entry_path(other_entry)
      expect(response).to have_http_status(:not_found)
    end
  end

  describe "PATCH /entries/:id (update)" do
    before { sign_in user }

    let(:new_attributes) { { name: "Updated Entry Name" } }

    context "with valid parameters" do
      it "updates the entry" do
        patch entry_path(entry), params: { entry: new_attributes }
        entry.reload
        expect(entry.name).to eq("Updated Entry Name")
      end

      it "redirects to entry" do
        patch entry_path(entry), params: { entry: new_attributes }
        expect(response).to redirect_to(entry)
      end

      it "sets flash notice with updated name" do
        patch entry_path(entry), params: { entry: new_attributes }
        expect(flash[:notice]).to include("Updated Entry Name")
      end

      it "responds to turbo stream" do
        patch entry_path(entry),
              params: { entry: new_attributes },
              headers: { "Accept" => "text/vnd.turbo-stream.html" }
        expect(response.media_type).to eq("text/vnd.turbo-stream.html")
      end
    end

    context "with invalid parameters" do
      let(:invalid_attributes) { { name: "" } }

      it "does not update the entry" do
        original_name = entry.name
        patch entry_path(entry), params: { entry: invalid_attributes }
        entry.reload
        expect(entry.name).to eq(original_name)
      end

      it "returns unprocessable entity status" do
        patch entry_path(entry), params: { entry: invalid_attributes }
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end

    it "returns 404 when updating other user's entry" do
      patch entry_path(other_entry), params: { entry: new_attributes }
      expect(response).to have_http_status(:not_found)
    end
  end

  describe "DELETE /entries/:id (destroy)" do
    before { sign_in user }

    it "destroys the entry" do
      entry_to_delete = create(:entry, user: user)
      expect {
        delete entry_path(entry_to_delete)
      }.to change(Entry, :count).by(-1)
    end

    it "redirects to root path" do
      delete entry_path(entry)
      expect(response).to redirect_to(root_path)
    end

    it "sets flash notice with entry name" do
      entry_name = entry.name
      delete entry_path(entry)
      expect(flash[:notice]).to include(entry_name)
    end

    it "responds to turbo stream" do
      delete entry_path(entry),
             headers: { "Accept" => "text/vnd.turbo-stream.html" }
      expect(response.media_type).to eq("text/vnd.turbo-stream.html")
    end

    it "returns 404 when destroying other user's entry" do
      delete entry_path(other_entry)
      expect(response).to have_http_status(:not_found)
    end
  end

  describe "authorization (user scoping)" do
    before { sign_in user }

    it "only shows current user entries in index" do
      user_entry = create(:entry, user: user, name: "User Entry")
      create(:entry, user: other_user, name: "Other Entry")

      get entries_path
      expect(response.body).to include("User Entry")
      expect(response.body).not_to include("Other Entry")
    end

    it "returns 404 when accessing other user entries via direct ID" do
      get entry_path(other_entry)
      expect(response).to have_http_status(:not_found)
    end
  end
end
