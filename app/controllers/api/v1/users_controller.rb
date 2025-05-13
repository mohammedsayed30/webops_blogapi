class Api::V1::UsersController < ApplicationController
  skip_before_action :authorize_request, only: [ :signup, :login ]
  # user's signup
  def signup
    # create a new user
    user = User.new(user_params)
    # user created successfully
    if user.save
      render json: {
        user: ActiveModelSerializers::SerializableResource.new(user),
        message: "user got  registered"
        }, status: :created
    # user not created
    else
      render json: { errors: user.errors.full_messages }, status: :unprocessable_entity
    end
  end

  # user's login
  def login
    # find user by email
    user = User.find_by(email: params[:email])
    if user&.authenticate(params[:password])
      # generate token
      token = JsonWebToken.encode(user_id: user.id)
      render json: {
        user: ActiveModelSerializers::SerializableResource.new(user),
        message: "User Loged in successful",
        token: token }, status: :ok
    else
      render json: { error: "Invalid Credentials" }, status: :unauthorized
    end
  end

  private
  def user_params
    params.permit(:name, :email, :password, :password_confirmation, :image)
  end
end
