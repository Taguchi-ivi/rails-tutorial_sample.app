require 'test_helper'

class MicropostTest < ActiveSupport::TestCase
  
  def setup
    @user = users(:michael)
    # 下記修正必要 今だけ使う
    # @micropost = Micropost.new(content: "Lorem ipsum", user_id: @user.id)
    @micropost = @user.microposts.build(content: "Lorem ipsum")
  end
  
  # @micropostの有効性確認
  test "should be valid" do
    # @micropostは有効か
    assert @micropost.valid?
  end
  
  # @micropostの無効な時に無効であることを確認
  test "user id should be present" do
    @micropost.user_id = nil
    # user_idをnilにした場合、有効とならないこと
    assert_not @micropost.valid?
  end
  
  # contentが存在しない場合はエラー
  test "countet should be present" do
    @micropost.content = "   "
    assert_not @micropost.valid?
  end
  
  # 140文字制限の確認
  test "content should be at most 140 characters" do
    @micropost.content = "a" * 141
    assert_not @micropost.valid?
  end
  
  # 降順になっているか確認
  test "order should be most recent first" do
    assert_equal microposts(:most_recent), Micropost.first
  end
  
  
  
  # test "the truth" do
  #   assert true
  # end
end
