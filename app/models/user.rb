class User < ApplicationRecord
  #userのバリディーションを設定
  #validates(:name,presence:true) 下と同義 空欄の制御
  #length: {maximum:00}文字列の制御　最大許容文字列数を記載
  #unipueness:true 重複を制御 {case_sensitive:false}これで小文字大文字関係なく一意性を確認する
  
  #仮装の属性を作成
  attr_accessor :remember_token
  
  # 保存する前にemailを小文字にする　Userモデルの中では右式のselfを省略できる
  # before_save { self.email = email.downcase }
  before_save { email.downcase! } #emailを直接変更しているのでコードが短くて済む
  
  validates :name, presence: true ,length: {maximum:50}
  
  VALID_EMAIL_REGEX =/\A[\w+\-.]+@[a-z\d\-]+(\.[a-z\d\-]+)*\.[a-z]+\z/i #本当の正規表現記載方法
  # VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i #メールアドレスの正規表現を定義　大文字から始まるものは定数foo@bar..comに対応していない
  
  validates :email, presence: true,length: {maximum:255},
                  format: {with:VALID_EMAIL_REGEX},
                  uniqueness: {case_sensitive: false}
                  
  
  # ハッシュのパスワードが作成できるようにする
  has_secure_password
  # パスワードのバリデーションを設定
  validates :password, presence: true, length: { minimum: 6 }
  
  
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
  def authenticated?(remember_token)
    # remember_digest(記憶ダイジェスト)がnilだったらfalseを返す
    # 処理を途中で終了する方法
    return false if remember_digest.nil?
    BCrypt::Password.new(remember_digest).is_password?(remember_token)
  end
  
  # ユーザーのログイン情報を破棄する
  def forget
    update_attribute(:remember_digest, nil)
  end
  
end
