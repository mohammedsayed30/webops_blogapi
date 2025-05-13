class Tag < ApplicationRecord
  # tag.rb
  has_many :post_tags, dependent: :destroy
  has_many :posts, through: :post_tags
  # unique name for each tag with case insensitive
  validates :name, presence: true, uniqueness: { case_sensitive: false }
end
