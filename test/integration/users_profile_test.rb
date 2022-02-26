require 'test_helper'

class UsersProfileTest < ActionDispatch::IntegrationTest
  include ApplicationHelper
  
  def setup
    @user = users(:michael)
  end
  
  # userプロフィール画面に対するテスト
  test "profile display" do
    get user_path(@user)
    assert_template 'users/show'
    assert_select 'title', full_title(@user.name)
    assert_select 'h1', text: @user.name
    # h1タグ（トップレベルの見出し）の内側にある、gravatarクラス付きのimgタグがあるかどうかをチェック
    assert_select 'h1>img.gravatar' 
    
    # following,followers件数を確認
    # 特定のHTMLタグが存在する→ strong id="following"
    assert_select 'strong#following'
    # 描写されたページに@user.following.countを文字列にしたものが含まれる
    assert_match @user.following.count.to_s, response.body
    # 特定のHTMLタグが存在する→ strong id="followers"
    assert_select 'strong#followers'
    # 描写されたページに@user.followers.countを文字列にしたものが含まれる
    assert_match @user.followers.count.to_s, response.body
    
    
    # response.body = そのページのHTMLが返される
    assert_match @user.microposts.count.to_s, response.body
    # 一つだけdivタグが存在することを確認
    assert_select 'div.pagination', count: 1
    @user.microposts.paginate(page: 1).each do |micropost|
      # 抽象的な探し方。どこかに存在すれば
      assert_match micropost.content, response.body
    end
  end
  
  # test "the truth" do
  #   assert true
  # end
end
