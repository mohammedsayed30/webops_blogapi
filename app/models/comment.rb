class Comment < ApplicationRecord
  # each comment belongs to a post
  # each comment belongs to a user
  belongs_to :post
  belongs_to :user
  # the body must be present
  validates :body, presence: true
end
