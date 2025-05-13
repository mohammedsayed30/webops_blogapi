class Api::V1::CommentsController < ApplicationController
  before_action :authorize_request
  before_action :set_comment, only: [ :update, :destroy ]
  before_action :authorize_comment!, only: [ :update, :destroy ]

  rescue_from ActiveRecord::RecordNotFound, with: :render_not_found
  # #create a new comment for a post
  def create
    post = Post.find(params[:post_id])
    comment = post.comments.build(comment_params)
    comment.user = current_user  # Assumes devise or token auth

    if comment.save
      render json: {
        message: "Comment created successfully",
        comment: CommentSerializer.new(comment)
      }, status: :created
    else
      render json: comment.errors, status: :unprocessable_entity
    end
  end
  # #get all comments for a post
  def index
    post = Post.find(params[:post_id])
    comments = post.comments.page(params[:page]).per(15)  # Kaminari pagination
    #check if the comment is empty
    if comments.empty?
      render json: { message: "No comments found" }, status: :ok
    else
      render json: comments, status: :ok
    end
  end

  # #update a comment
  def update
    if @comment.update(comment_params)
      render json: @comment
    else
      render json: @comment.errors, status: :unprocessable_entity
    end
  end

def destroy
  @comment.destroy
  render json: { message: "the comment deleted successfully" }, status: :ok
end

private

def comment_params
  params.permit(:body)
end

def set_comment
  @comment = Comment.find(params[:id])
end

def authorize_comment!
  render json: { error: "Not authorized" }, status: :unauthorized unless @comment.user == current_user
end

def render_not_found(exception)
  render json: { error: "Comments or Post not found ,maybe it is got deleted" }, status: :not_found
end
end
