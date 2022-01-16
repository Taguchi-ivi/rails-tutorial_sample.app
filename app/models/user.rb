class User < ApplicationRecord
  #userのバリディーションを設定
  #validates(:name,presence:true) 下と同義 空欄の制御
  #length: {maximum:00}文字列の制御　最大許容文字列数を記載
  #unipueness:true 重複を制御 {case_sensitive:false}これで小文字大文字関係なく一意性を確認する
  VALID_EMAIL_REGEX =/\A[\w+\-.]+@[a-z\d\-]+(\.[a-z\d\-]+)*\.[a-z]+\z/i #本当の正規表現記載方法
  # VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i #メールアドレスの正規表現を定義　大文字から始まるものは定数foo@bar..comに対応していない
  
  # 保存する前にemailを小文字にする　Userモデルの中では右式のselfを省略できる
  # before_save { self.email = email.downcase }
  before_save { email.downcase! } #emailを直接変更しているのでコードが短くて済む
  
  validates :name, presence: true ,length: {maximum:50}
  validates :email, presence: true,length: {maximum:255},
                  format: {with:VALID_EMAIL_REGEX},
                  uniqueness: {case_sensitive: false}
                  
  
  # ハッシュのパスワードが作成できるようにする
  has_secure_password
  # パスワードのバリデーションを設定
  validates :password, presence: true, length: { minimum: 6 }
  
end
