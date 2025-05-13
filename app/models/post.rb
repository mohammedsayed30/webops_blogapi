class Post < ApplicationRecord
  # to delete a post after 24 hours
  after_create :schedule_post_deletion
  # asigns a post to a user
  belongs_to :user
  # eah post can have many comments
  has_many :comments, dependent: :destroy
  # each post can have many tags
  # has_and_belongs_to_many :tags
  has_many :post_tags, dependent: :destroy
  has_many :tags, through: :post_tags

  validates :title, :body, presence: true
  validate :must_have_at_least_one_tag

  # Create or find tags from names
  def assign_tags_by_names(tags)
    self.tags = tags.map { |name| Tag.find_or_create_by(name: name.downcase.strip) }
  end

  private

  # Custom validation to ensure the post has at least one tag
  def must_have_at_least_one_tag
    if tags.blank?
      errors.add(:tags, "must have at least one tag")
    end
  end
  # Schedule the post deletion job
  def schedule_post_deletion
    # Schedule the deletion job to run after 24 hours
    PostDeletionJob.set(wait: 24.hours).perform_later(self.id)
  end
end
