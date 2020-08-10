class Micropost < ApplicationRecord
  belongs_to :user

  PERMITTED_PARAMS = %i(content image).freeze

  has_one_attached :image

  validates :user_id, presence: true
  validates :content, presence: true, length: {maximum: 140}
  validates :image,
            content_type: {
              in: Settings.validate.micropost.image_content_type,
              message: I18n.t("microposts.validate.image_format")
            },
            size: {
              less_than: Settings.validate.micropost.image_maxsize.megabytes,
              message: I18n.t(
                "microposts.validate.image_size",
                size: Settings.validate.micropost.image_maxsize
              )
            }

  paginates_per Settings.pagination.per_page

  scope :order_by_created_at_desc, ->{order created_at: :desc}

  def display_image
    size_limit = Settings.image.micropost.size_limit
    image.variant resize_to_limit: [size_limit, size_limit]
  end
end
