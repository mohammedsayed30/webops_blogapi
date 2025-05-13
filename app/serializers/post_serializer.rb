class PostSerializer < ActiveModel::Serializer
  attributes :id, :title, :body, :user_id
  has_many  :tags
  has_many  :comments
end
