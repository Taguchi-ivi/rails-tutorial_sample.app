class User < ApplicationRecord
  
  # micropostと関連付け user1に対してmicropost複数
  # 引数にdestroyを付与して、権限があるものがuserを削除したらすべてのデータが消えることを指定
  has_many :microposts, dependent: :destroy
  
  # relationshipと関連づけ,class名が存在しないので明示的に指定する
  # ユーザーが削除されたら全て消す設定dependent :destroyも設定
  # フォロー
  has_many :active_relationships, class_name:  "Relationship",
                                  foreign_key: "follower_id",
                                  dependent:   :destroy
  
  # フォロワー
  has_many :passive_relationships, class_name:  "Relationship",
                                   foreign_key: "followed_id",
                                   dependent:   :destroy
  
  
  # 多対多 デフォルトの設定を上書きして、わかりやすい名前に(followingとはfollowed idの集合)
  # フォロー
  has_many :following, through: :active_relationships, source: :followed
  
  # フォロワー
  has_many :followers, through: :passive_relationships, source: :follower
  
  
  
  #userのバリディーションを設定
  #validates(:name,presence:true) 下と同義 空欄の制御
  #length: {maximum:00}文字列の制御　最大許容文字列数を記載
  #unipueness:true 重複を制御 {case_sensitive:false}これで小文字大文字関係なく一意性を確認する
  
  #仮想の属性を作成
  attr_accessor :remember_token, :activation_token, :reset_token
  # 保存する前にする処理 downcase_emailメソッド
  before_save   :downcase_email
  # Userを作成する前にする処理 create_activation_digestメソッド
  before_create :create_activation_digest
  
  # 保存する前にemailを小文字にする　Userモデルの中では右式のselfを省略できる
  # before_save { self.email = email.downcase }
  # before_save { email.downcase! } #emailを直接変更しているのでコードが短くて済む
  
  validates :name, presence: true ,length: {maximum:50}
  
  VALID_EMAIL_REGEX =/\A[\w+\-.]+@[a-z\d\-]+(\.[a-z\d\-]+)*\.[a-z]+\z/i #本当の正規表現記載方法
  # VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i #メールアドレスの正規表現を定義　大文字から始まるものは定数foo@bar..comに対応していない
  
  validates :email, presence: true,length: {maximum:255},
                  format: {with:VALID_EMAIL_REGEX},
                  uniqueness: {case_sensitive: false}
                  
  
  # ハッシュのパスワードが作成できるようにする
  has_secure_password
  # パスワードのバリデーションを設定
  # validates :password, presence: true, length: { minimum: 6 }
  # has_secure_passwordで空欄を許容していないため、新規レコードではエラーになる。既存のレコードはpassが空欄も許容
  validates :password,presence: true, length: { minimum: 6 }, allow_nil:true
  
  
  class << self
    
    # 渡された文字列のハッシュ値を返す
    # self = User
    # def self.digest(string)
    def digest(string)
      cost = ActiveModel::SecurePassword.min_cost ? BCrypt::Engine::MIN_COST :
                                                    BCrypt::Engine.cost
      BCrypt::Password.create(string, cost: cost)
    end
    
    # ランダムなトークンを返す
    # self = User
    # def self.new_token
    def new_token
      SecureRandom.urlsafe_base64
    end
  end
  
  # 永続セッションのために、ユーザーをデータベースに記憶する
  def remember
    self.remember_token = User.new_token
    # バリデーションを無視して更新（引数にハッシュで更新したい属性と値をセット）
    update_attribute(:remember_digest, User.digest(remember_token))
  end
  
  # 渡されたトークンがダイジェストと一致していたらtrueを返す
  def authenticated?(attribute, token)
    # remember_digest(記憶ダイジェスト)がnilだったらfalseを返す
    # 処理を途中で終了する方法
    # return false if remember_digest.nil?
    # BCrypt::Password.new(remember_digest).is_password?(remember_token)
    
    # リファクタリング
    digest = send("#{attribute}_digest")
    return false if digest.nil?
    BCrypt::Password.new(digest).is_password?(token)
  
  end
  
  
  # ユーザーのログイン情報を破棄する
  def forget
    update_attribute(:remember_digest, nil)
  end
  
  
  # ----
  # ユーザー操作の一部をコントローラからモデルに移動する
  # アカウントを有効にする
  def activate
    # user.update_attributeではなく、下記でOK,selfなら許容だがselfさえ不要になる(selfはモデル内では必須ではない)
    # update_attribute(:activated, true)
    # update_attribute(:activated_at, Time.zone.now)
    # 上記では二回データベースに問い合わせているため、一回にまとめる
    update_columns(activated: true, activated_at: Time.zone.now)
  end
  
  # 有効化用のメールを送信する
  def send_activation_email
    UserMailer.account_activation(self).deliver_now
  end
  
  # パスワード再設定の属性を設定する
  def create_reset_digest
    self.reset_token = User.new_token
    # update_attribute(:reset_digest,  User.digest(reset_token))
    # update_attribute(:reset_sent_at, Time.zone.now)
    # 二個をupdateするところを一個にまとめる
    update_columns(reset_digest: User.digest(reset_token), reset_sent_at: Time.zone.now)
    
  end
  
  # パスワード再設定のメールを送信
  def send_password_reset_email
    UserMailer.password_reset(self).deliver_now
  end
  
  # パスワード再設定の期限が切れている場合はtrueを返す
  # 2時間より少ない(より早い)場合はエラー =現在時刻より2時間以上前（早い）の場合
  def password_reset_expired?
    reset_sent_at < 2.hours.ago
  end
  
  # 試作feedを定義 SQL文に変数を代入する場合は常にエスケープする習慣を。　セキュリティ上の関係で
  # ユーザーのステータスフィードを返す
  def feed
    # Micropost.where("user_id = ?" , id)
    # following_idsメソッドは、has_many :followingの関連付けをしたときにActive Recordが自動生成したもの
    # 自身を含めたフォローしている投稿をすべて表示,following_idsは自動生成メソッドフォローしているidをすべて返す(,区切りで)
    # Micropost.where("user_id IN (?) OR user_id = ?", following_ids, id)
    # 同じ変数を違う箇所でも使いたい場合こっちの方が便利
    # Micropost.where("user_id IN (:following_ids) OR user_id = :user_id",
    #                 following_ids: following_ids, user_id: id)
    # さらにリファクタリング。
    # フォロー数が多いと遅くなる可能性を加味して.サブセレクトを使用
    following_ids = "SELECT followed_id FROM relationships 
                     WHERE follower_id = :user_id"
    Micropost.where("user_id IN (#{following_ids}) 
                     OR user_id = :user_id", user_id: id)
    
  end
  
  # ユーザーをフォローする
  def follow(other_user)
    # 配列に追加する
    following << other_user
  end
  
  # フォローを解除
  def unfollow(other_user)
    active_relationships.find_by(followed_id: other_user.id).destroy
  end
  
  # 現在ユーザーがフォローしていたらtrueを返す,includeメソッドで存在を確認
  def following?(other_user)
    following.include?(other_user)
  end
  
  # この場所だけで使用、隠蔽できる
  private
    
    # メールアドレスを全て小文字にする
    def downcase_email
      # self.email = email.downcase
      self.email.downcase!
    end
    
    # 有効化トークンとダイジェストを作成及び代入する
    def create_activation_digest
      self.activation_token  = User.new_token
      self.activation_digest = User.digest(activation_token)  # DBと関連づけられているため、保存処理を行うと一緒に保存される
    end
  
end
