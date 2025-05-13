class Api::V1::PostsController < ApplicationController
  before_action :authorize_request
  before_action :set_post, only: [ :show, :update, :destroy, :update_tags ]
  before_action :authorize_post!, only: [ :update, :destroy, :update_tags ]

  rescue_from ActiveRecord::RecordNotFound, with: :render_not_found
  def index
    # Fetch all posts with their associated tags and comments
    posts = Post.includes(:tags, :comments).all
    if posts.empty?
      render json: { message: "No posts found" }, status: :ok
    else
    render json: posts, status: :ok
    end
  end

 def show
  post = Post.find_by(id: params[:id])
  if post
    render json: post, status: :ok
  else
    render json: { error: "Post with id=#{params[:id]} not found" }, status: :not_found
  end
 end

  def create
    # Create a new post with the current user as the author
    post = current_user.posts.build(post_params.except(:tags))
    # Assign tags to the post if provided
    post.assign_tags_by_names(post_params[:tags]) if post_params[:tags].present?

    if post.valid? && post.save
      render json: post, status: :created
    else
      render json: post.errors, status: :unprocessable_entity
    end
  end

  def update
    # update the tags if provided
    if post_params[:tags].present?
      @post.assign_tags_by_names(post_params[:tags])
    end
    # update the post without tags
    if @post.update(post_params.except(:tags))
      render json: @post, status: :ok
    else
      render json: @post.errors, status: :unprocessable_entity
    end
  end
  # delete the post
  def destroy
    if @post.destroy
    render json: { message: "Post deleted successfully" }, status: :ok
    else
      render json: { error: "Failed to delete post" }, status: :not_found
    end
  end
# update the tags of the post
def update_tags
  if post_params[:tags].present?
    @post.assign_tags_by_names(post_params[:tags])

    if @post.valid? && @post.save
      render json: @post, status: :ok
    else
      render json: @post.errors, status: :unprocessable_entity
    end
  else
    render json: { error: "Tags can't be empty" }, status: :unprocessable_entity
  end
end
# get the posts for a user
def user_posts
  user = User.find_by(id: params[:user_id])
  if user
    posts = user.posts.includes(:tags, :comments)
    if posts.empty?
      render json: { message: "No posts found for this user" }, status: :ok
    else
      render json: posts, status: :ok
    end
  else
    render json: { error: "User not found" }, status: :not_found
  end
end
# get my posts
def my_posts
  posts = current_user.posts.includes(:tags, :comments)
  if posts.empty?
    render json: { message: "No posts found for this user" }, status: :ok
  else
    render json: posts, status: :ok
  end
end

  private

  def set_post
    @post = Post.find(params[:id])
  end

  def authorize_post!
    render json: { error: "Not authorized" }, status: :unauthorized unless @post.user == current_user
  end

  def post_params
    params.permit(:title, :body, tags: [])
  end
  # This method will now handle any RecordNotFound in this controller
  def render_not_found(exception)
    render json: { error: "Post not found ,maybe it is got deleted" }, status: :not_found
  end
end
