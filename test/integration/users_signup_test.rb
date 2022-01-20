require 'test_helper'

class UsersSignupTest < ActionDispatch::IntegrationTest
  
  
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
  test "valid signup infomation" do
    get signup_path
    # 第二引数に増えた件数を記載
    assert_difference 'User.count',1 do
      
      post users_path, params:{ user: { name: "Example User",
                                        email: "user@example.com",
                                        password: "password",
                                        password_confirmation: "password" } }
    end
    
    # 指定されたリダイレクト先に移動するメソッド
    follow_redirect!
    # urlが遷移先になっていることを確認
    assert_template 'users/show'
    # assert_not flash.empty?   #flashの中身が空でないかテスト
    
    # テスト用ユーザーがログイン中か確認
    assert is_logged_in?
  end
  
  
  # test "the truth" do
  #   assert true
  # end
end
