class PostDeletionJob < ApplicationJob
  queue_as :default

  def perform(post_id)
    # get the post from the database
    post = Post.find_by(id: post_id)
    # check if the post exists and created from 24 hours
    if post
      # delete the post
      post.destroy
    end
    # Do something later
  end
end
