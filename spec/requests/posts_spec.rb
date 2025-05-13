require 'rails_helper'

RSpec.describe "Posts API", type: :request do
  let(:user) { User.create!(name: "Test", email: "test@example.com", password: "password", password_confirmation: "password") }
  let(:headers) { { "Authorization" => "Bearer #{JWT.encode({ user_id: user.id }, "virtualsecretkey") }" } }
  let!(:tag1) { Tag.create!(name: "Tag1") }
  let!(:tag2) { Tag.create!(name: "Tag2") }
  let!(:post_record) { Post.create!(title: "Sample Post", body: "Sample Body", user: user, tags: [ tag1 ]) }

  describe "POST /posts" do
    it "creates a post with tags" do
      post "/api/v1/posts", params: {
        title: "New Post",
        body: "New body",
        tags: [ tag1, tag2 ]
      }, headers: headers

      expect(response).to have_http_status(:created)
      json = JSON.parse(response.body)
      expect(json["title"]).to eq("New Post")
    end

    it "fails to create post without title" do
      post "/api/v1/posts", params: { body: "No title", tags: [ "Tag1" ] }, headers: headers
      expect(response).to have_http_status(:unprocessable_entity)
    end
  end

  describe "GET /posts" do
    it "returns all posts" do
      get "/api/v1/posts", headers: headers
      expect(response).to have_http_status(:success)
      expect(JSON.parse(response.body).length).to be >= 1
    end
     it "fails to delete with invalid url" do
      delete "/api/v1/pos", headers: headers
      expect(response).to have_http_status(:not_found)
    end
  end

  describe "GET /posts/:id" do
    it "returns specific post" do
      get "/api/v1/posts/#{post_record.id}", headers: headers
      expect(response).to have_http_status(:success)
      expect(JSON.parse(response.body)["title"]).to eq("Sample Post")
    end

    it "returns not found for invalid id" do
      get "/api/v1/posts/9999", headers: headers
      expect(response).to have_http_status(:not_found)
    end
  end

  describe "PUT /posts/:id" do
    it "updates a post" do
      put "/api/v1/posts/#{post_record.id}", params: { title: "Updated" }, headers: headers
      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body)["title"]).to eq("Updated")
    end

    it "fails to update with invalid data" do
      put "/api/v1/posts/#{post_record.id}", params: { title: "" }, headers: headers
      expect(response).to have_http_status(:unprocessable_entity)
    end
  end

  describe "DELETE /posts/:id" do
    it "deletes a post" do
      delete "/api/v1/posts/#{post_record.id}", headers: headers
      expect(response).to have_http_status(:ok)
    end
     it "fails to delete with invalid url" do
      delete "/api/v1/pos/#{post_record.id}", headers: headers
      expect(response).to have_http_status(:not_found)
    end
  end

  describe "PATCH /posts/:id/update_tags" do
  it "updates tags of a post" do
    patch "/api/v1/posts/#{post_record.id}/update_tags",
      params: { tags: [ "tag3" ]
    },  headers: headers

    expect(response).to have_http_status(:ok)
    expect(post_record.reload.tags.pluck(:name)).to include("tag3")
  end

    it "fails if tags param is missing" do
      patch "/api/v1/posts/#{post_record.id}/update_tags", headers: headers
      expect(response).to have_http_status(:unprocessable_entity)
    end
  end

  describe "Unauthorized access" do
    it "denies access without token" do
      get "/api/v1/posts"
      expect(response).to have_http_status(:unauthorized)
    end
  end
end
