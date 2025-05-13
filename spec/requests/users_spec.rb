require 'rails_helper'

RSpec.describe "User Signup and Login", type: :request do
  let(:signup_url) { "http://127.0.0.1:3000/api/v1/users/signup" }
  let(:login_url) { "http://127.0.0.1:3000/api/v1/users/login" }

  describe "POST /signup" do
    context "with valid data" do
      it "creates a user and returns success" do
        image = fixture_file_upload(Rails.root.join("spec/fixtures/files/avatar.jpg"), "image/jpg")

        post signup_url, params: {
          name: "Test User",
          email: "user@example.com",
          password: "password",
          password_confirmation: "password",
          image: image
        }

        expect(response).to have_http_status(:created)
        json = JSON.parse(response.body)
        expect(json["message"]).to eq("user got  registered")
        expect(json["user"]["email"]).to eq("user@example.com")
      end
    end

    context "with invalid data" do
      it "returns error for missing password" do
        post signup_url, params: {
          name: "Test User",
          email: "user@example.com",
          password: "",
          password_confirmation: ""
        }

        expect(response).to have_http_status(:unprocessable_entity)
        json = JSON.parse(response.body)
        expect(json["errors"]).to include("Password can't be blank")
      end
    end
  end

  describe "POST /login" do
    before do
      User.create!(
        name: "Login Test",
        email: "login@example.com",
        password: "secure123",
        password_confirmation: "secure123"
      )
    end

    context "with valid credentials" do
      it "logs in and returns token" do
        post login_url, params: {
          email: "login@example.com",
          password: "secure123"
        }

        expect(response).to have_http_status(:ok)
        json = JSON.parse(response.body)
        expect(json["token"]).to be_present
        expect(json["user"]["email"]).to eq("login@example.com")
      end
    end

    context "with invalid credentials" do
      it "returns unauthorized error" do
        post login_url, params: {
          email: "login@example.com",
          password: "wrong"
        }

        expect(response).to have_http_status(:unauthorized)
        json = JSON.parse(response.body)
        expect(json["error"]).to eq("Invalid Credentials")
      end
    end
  end
end
