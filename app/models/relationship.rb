class Relationship < ApplicationRecord
  
  # 関連付け follower,followed1に対してuserは1
  belongs_to :follower, class_name: "User"
  belongs_to :followed, class_name: "User"
  
  # バリデーション 空欄nilの制御 コメントアウトしてもテストが通る。ただししっかりと記載しておくのが吉
  validates :follower_id, presence: true
  validates :followed_id, presence: true
  
end
