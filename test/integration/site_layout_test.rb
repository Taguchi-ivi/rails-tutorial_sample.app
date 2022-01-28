require 'test_helper'

class SiteLayoutTest < ActionDispatch::IntegrationTest
  # test "the truth" do
  #   assert true
  # end
  
  # ログインしていない状態のテスト
  test "layout links when not logged in" do
    get root_path
    assert_template  'static_pages/home'
    
    assert_select "a[href=?]", root_path,count:2
    assert_select "a[href=?]",help_path
    assert_select "a[href=?]",about_path
    assert_select "a[href=?]",contact_path
    assert_select "a[href=?]",signup_path
    assert_select "a[href=?]",login_path
    get contact_path
    assert_select "title",full_title("Contact")
    get signup_path
    assert_select "title",full_title("Sign up")
  end
  
  # テストユーザーを作成
  def setup
    @user = users(:michael)
  end
  
  # ログインしている状態のテスト
  test "Layput links when logged in" do
    # ログイン
    log_in_as(@user)
    # ルートパスへゲットリクエスト
    get root_path
    # static-pages/homeが正しく表示されること
    assert_template 'static_pages/home'
    # リンクの妥当性確認
    assert_select "a[href=?]",root_path, count:2
    assert_select "a[href=?]", help_path
    assert_select "a[href=?]", users_path
    assert_select "a[href=?]", user_path(@user)
    assert_select "a[href=?]", edit_user_path(@user) 
    assert_select "a[href=?]", logout_path
    assert_select "a[href=?]", about_path
    assert_select "a[href=?]", contact_path
  end
  
  
  
end
