require 'test_helper'

class PasswordResetsTest < ActionDispatch::IntegrationTest
  
  def setup
    ActionMailer::Base.deliveries.clear
    @user = users(:michael)
  end
  
  test "password resets" do
    get new_password_reset_path
    assert_template 'password_resets/new'
    assert_select 'input[name=?]', 'password_reset[email]'
    
    # メールアドレスが無効
    post password_resets_path, params: { password_reset: { email: "" } }
    assert_not flash.empty?
    assert_template 'password_resets/new'
    
    # メールアドレスが有効
    post password_resets_path,params: { password_reset: { email: @user.email } }
    assert_not_equal @user.reset_digest, @user.reload.reset_digest
    # 引数の値が等しい １とActionMailer::Base.deliveriesに格納された配列の数
    assert_equal 1, ActionMailer::Base.deliveries.size
    assert_not flash.empty?
    assert_redirected_to root_url
    
    # パスワード再設定フォームのテスト
    user = assigns(:user)
    
    # メールアドレスが無効
    get edit_password_reset_path(user.reset_token, email: "")
    assert_redirected_to root_url
    
    # 無効なユーザー
    user.toggle!(:activated)
    get edit_password_reset_path(user.reset_token, email: user.email)
    assert_redirected_to root_url
    user.toggle!(:activated)
    
    # メールアドレスが有効でトークンが無効
    get edit_password_reset_path('wrong token', email: user.email)
    assert_redirected_to root_url
    
    # メールアドレスもトークンも有効
    get edit_password_reset_path(user.reset_token, email: user.email)
    assert_template 'password_resets/edit'
    # inputにhidden属性の値がメールアドレスであることを確認
    assert_select "input[name=email][type=hidden][value=?]", user.email
    
    # 無効なパスワードとパスワードを確認
    patch password_reset_path(user.reset_token), params: { email: user.email,
                                                           user: { password:              "foobaz",
                                                                   password_confirmation: "barquux" } }
    assert_select 'div#error_explanation'
    
    # パスワードが空
    patch password_reset_path(user.reset_token), params: { email: user.email,
                                                           user: { password:              "",
                                                                   password_confirmation: "" } }
    assert_select 'div#error_explanation'
    
    # 有効なパスワードとパスワードを確認
    patch password_reset_path(user.reset_token), params: { email: user.email,
                                                           user: { password:              "foobaz",
                                                                   password_confirmation: "foobaz" } }
    assert is_logged_in?
    
    # nilであればture → 再取得したuserのreset_digest
    assert_nil user.reload.reset_digest
    
    assert_not flash.empty?
    assert_redirected_to user
    
  end
  
  # パスワード再設定の期限切れを確認
  test "expired token" do
    get new_password_reset_path
    post password_resets_path, params: { password_reset: { email: @user.email } }
    
    # @userに@userを代入（通常統合テストからはアクセスできないattr_accessorで定義した属性の値にもアクセスできるようになる）
    @user = assigns(:user)
    # 3時間前に上書き
    @user.update_attribute(:reset_sent_at, 3.hours.ago)
    patch password_reset_path(@user.reset_token), params: { email: @user.email,
                                                           user: { password:              "foobaz",
                                                                   password_confirmation: "foobaz" } }
    # レスポンスは以下のredirectになるはず
    assert_response :redirect
    # POSTの送信結果に沿って指定されたリダイレクト先に移動
    follow_redirect!
    
    # response.bodyは、そのページのHTML本文をすべて返すメソッド
    # リダイレクトされたページに'有効期限が切れています'が含まれている
    assert_match /expired/i, response.body
    
  end
  
  
  
  
  
  # test "the truth" do
  #   assert true
  # end
end
