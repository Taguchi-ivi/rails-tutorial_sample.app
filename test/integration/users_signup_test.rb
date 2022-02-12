require 'test_helper'

class UsersSignupTest < ActionDispatch::IntegrationTest
  
  # deliveriesは変数なので最初に初期化
  # テスト中のメール送信モードをtestに設定している
  # 送信されたメールはdeliveriesと言う変数に格納されていく
  def setup
    ActionMailer::Base.deliveries.clear
  end

  # 無効なユーザー登録に対するテスト
  # 元のユーザー数ととテスト後(失敗するはずのテスト)をしてユーザー数が変化していないことを確認する
  test "invalid signup information" do
    get signup_path 
    assert_no_difference 'User.count' do
      
      post users_path, params:{ user: { name: "",
                                        email: "user@invalid",
                                        password: "foo",
                                        password_confirmation: "bar" } }
    
    end
    # 登録できた画面に遷移できていないこと。遷移していないことを確認する
    assert_template 'users/new'
    
    # エラーメッセージに対するテスト
    assert_select 'div#error_explanation'
    assert_select 'div.alert'
    assert_select 'div.alert-danger'
  end
  
  # 有効なユーザー登録に対してのテスト
  # 新規登録が成功していることを確認するため、レコードが一見増えることを確認
  test "valid signup information with account activation" do
    get signup_path
    # 第二引数に増えた件数を記載
    assert_difference 'User.count', 1 do
      
      post users_path, params:{ user: { name: "Example User",
                                        email: "user@example.com",
                                        password: "password",
                                        password_confirmation: "password" } }
    end
    
    # 配信されたメッセージがきっかり1であることを確認する
    assert_equal 1, ActionMailer::Base.deliveries.size
    # インスタンス変数にアクセスできる @user
    user = assigns(:user)
    assert_not user.activated?
    # 有効化していない状態でログインしてみる
    log_in_as(user)
    # ログインできていないことを確認 以下二つも同義
    assert_not is_logged_in?
    # 有効化トークンが不正な場合
    get edit_account_activation_path("invalid token", email: user.email)
    assert_not is_logged_in?
    # トークンは正しいがメールアドレスが無効な場合
    get edit_account_activation_path(user.activation_token, email: 'wrong')
    assert_not is_logged_in?
    # 有効化トークンが正しい場合
    get edit_account_activation_path(user.activation_token, email: user.email)
    assert user.reload.activated?
    # 指定されたリダイレクト先に移動するメソッド
    follow_redirect!
    
    assert_template 'users/show'
    assert is_logged_in?
    
  end
  
  
  # test "the truth" do
  #   assert true
  # end
end
