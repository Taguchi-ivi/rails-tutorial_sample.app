class Micropost < ApplicationRecord
  # 1つの投稿に対して、userは1
  belongs_to :user
  
  # 1つの投稿に対して、image1つ
  has_one_attached :image
  
  # 降順、新しいものから表示されるように設定を変更 DESC
  default_scope -> { order(created_at: :desc) }
  
  # user_idが存在する
  validates :user_id, presence: true
  # contentが存在する && 140文字まで
  validates :content, presence: true, length: { maximum: 140 }
  
  # imageのバリデーション active_strage
  validates :image, content_type: { in: %w[image/jpeg image/gif image/png],
                                    message: "must be a valid image format" } ,
                    size:         {less_than: 5.megabytes,
                                    message: "should be less than 5BM" }
  
  # micropostで投稿する画像をリサイズ
  def display_image
    image.variant(resize_to_limit: [500,500])
  end
  
end
