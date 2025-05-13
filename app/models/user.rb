class User < ApplicationRecord
  # use active storage for image upload
  has_one_attached :image
  # for hashed password and password confirmation
  has_secure_password
  # user can have many posts
  has_many :posts,  dependent: :destroy
  # user can have many comments
  has_many :comments, dependent: :destroy

  # validations
  # Validate name
  validates :name, presence: true, length: { minimum: 3, maximum: 50 }
  # validate email
  validates :email, presence: true, uniqueness: true
  validates :email, format: {
    with: URI::MailTo::EMAIL_REGEXP,
    message: "must be a valid email address"
  }

  # Validate password
  validates :password, confirmation: true, length: { minimum: 6 }, if: -> { new_record? || !password.nil? }

  # Image: optional, but must match format if provided
  validates :image, content_type: [ "image/png", "image/jpeg", "image/gif" ], allow_blank: true
end
