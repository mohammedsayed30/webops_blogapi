require 'rails_helper'

RSpec.describe "Comments API", type: :request do
  let(:user) do
  User.create!(
    name: "Test",
    email: "test@example.com",
    password: "password",
    password_confirmation: "password"
  )
end

let!(:tag) { Tag.create!(name: "test-tag") }

let(:headers) do
  {
    "Authorization" => "Bearer #{JWT.encode({ user_id: user.id }, Rails.application.credentials.secret_key_base) }"
  }
end

let!(:post_record) do
  Post.create!(
    title: "Sample Post",
    body: "Sample Body",
    user: user,
    tags: [ tag ]
  )
end


let!(:comment) do
  Comment.create!(
    body: "This is a comment",
    user: user,
    post: post_record
  )
end
let(:json) { JSON.parse(response.body) }
  describe "POST /posts/:post_id/comments" do
    it "creates a comment successfully" do
      post "/api/v1/posts/#{post_record.id}/comments", params: {
        body: "This is a test comment"
      }, headers: headers

      expect(response).to have_http_status(:created)
      parsed = JSON.parse(response.body)
      expect(parsed['comment']['body']).to eq("This is a test comment")
    end

    it "fails without body" do
      post "/api/v1/posts/#{post_record.id}/comments", params: {}, headers: headers
      expect(response).to have_http_status(:unprocessable_entity)
      json = JSON.parse(response.body)
      expect(json['body']).to include("can't be blank")
    end

    it "fails if post does not exist" do
      post "/api/v1/posts/9999/comments", params: { body: "Hello" }, headers: headers
      expect(response).to have_http_status(:not_found)
    end
  end

  describe "PUT /comments/:id" do
    it "updates a comment" do
      put "/api/v1/comments/#{comment.id}", params: { body: "Updated comment" }, headers: headers
      expect(response).to have_http_status(:ok)
      expect(json['body']).to eq("Updated comment")
    end

    it "fails if body is empty" do
      put "/api/v1/comments/#{comment.id}", params: { body: "" }, headers: headers
      expect(response).to have_http_status(:unprocessable_entity)
      expect(json['body']).to include("can't be blank")
    end

    it "fails for invalid comment ID" do
      put "/api/v1/comments/9999", params: { body: "X" }, headers: headers
      expect(response).to have_http_status(:not_found)
    end
  end

  describe "GET /posts/:post_id/comments" do
    it "lists all comments for a post" do
      get "/api/v1/posts/#{post_record.id}/comments", headers: headers
      expect(response).to have_http_status(:ok)
      expect(json).to be_an(Array)
      expect(json.first['body']).to eq(comment.body)
    end

    it "fails for non-existent post" do
      get "/api/v1/posts/9999/comments", headers: headers
      expect(response).to have_http_status(:not_found)
    end
  end

  describe "DELETE /comments/:id" do
    it "deletes a comment" do
      delete "/api/v1/comments/#{comment.id}", headers: headers
      expect(response).to have_http_status(:ok)
      expect(json['message']).to eq("the comment deleted successfully")
    end

    it "fails for invalid comment ID" do
      delete "/api/v1/comments/9999", headers: headers
      expect(response).to have_http_status(:not_found)
    end
  end
end
