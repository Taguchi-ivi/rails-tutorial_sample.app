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
