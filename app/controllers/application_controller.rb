class ApplicationController < ActionController::API
  before_action :authorize_request

  def current_user
    @current_user
  end

  def authorize_request
    header = request.headers["Authorization"]
    token = header.split(" ").last if header

    decoded = JsonWebToken.decode(token)
    return render json: { errors: "Unauthorized request" }, status: :unauthorized unless decoded

    @current_user = User.find(decoded[:user_id])
  rescue ActiveRecord::RecordNotFound, JWT::DecodeError
    render json: { errors: "Unauthorized request" }, status: :unauthorized
  end

    # Handle route not found
    def route_not_found
      render json: {
        error: "Endpoint not found",
        suggestion: "Check  WebOps Collections  for valid endpoints"
      }, status: :not_found
    end
end
