require 'test_helper'

class UserMailerTest < ActionMailer::TestCase
  test "account_activation" do
    # mail = UserMailer.account_activation
    # assert_equal "Account activation", mail.subject
    # assert_equal ["to@example.org"], mail.to
    # assert_equal ["from@example.com"], mail.from
    # assert_match "Hi", mail.body.encoded
    
    # 第一引数の正規表現の値と第二引数の値がマッチすれば成功
    # assert_match 正規表現も一致しているか確認できる
    
    user = users(:michael)
    user.activation_token = User.new_token
    mail = UserMailer.account_activation(user)
    assert_equal "Account activation", mail.subject
    assert_equal [user.email], mail.to
    assert_equal ["noreply@example.com"], mail.from
    assert_match user.name,               mail.body.encoded
    assert_match user.activation_token,   mail.body.encoded
    assert_match CGI.escape(user.email),  mail.body.encoded
    
  end
  
  test "password_reset" do
    
    # データ取得
    user = users(:michael)
    # 新規トークンを取得
    user.reset_token = User.new_token
    
    mail = UserMailer.password_reset(user)
    
    # 件名が一致していることを確認
    assert_equal  "Password reset", mail.subject
    # メールの送信者と取得したメールアドレスが一致していること
    assert_equal [user.email], mail.to
    # 送り主がnoreply@example.comであること
    assert_equal ["noreply@example.com"], mail.from
    # トークンが正規表現で存在すること 
    assert_match user.reset_token,        mail.body.encoded
    # メールアドレスが正規が正規表現で存在すること
    assert_match CGI.escape(user.email),  mail.body.encoded
    
      
  end

  # test "password_reset" do
  #   mail = UserMailer.password_reset
  #   assert_equal "Password reset", mail.subject
  #   assert_equal ["to@example.org"], mail.to
  #   assert_equal ["from@example.com"], mail.from
  #   assert_match "Hi", mail.body.encoded
  # end

end
