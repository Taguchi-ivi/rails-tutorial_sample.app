require 'test_helper'

class FollowingTest < ActionDispatch::IntegrationTest
  
  def setup
    @user = users(:michael)
    @other = users(:archer)
    log_in_as(@user)
  end
  
  # ページテスト
  
  test "following page" do
    get following_user_path(@user)
    # emptyの場合、ループ分がエラーにならないため、一応確認
    assert_not @user.following.empty?
    assert_match @user.following.count.to_s, response.body
    @user.following.each do |user|
      assert_select "a[href=?]", user_path(user)
    end
  end
  
  test "followers page" do
    get followers_user_path(@user)
    # emptyの場合、ループ分がエラーにならないため、一応確認
    assert_not @user.followers.empty?
    assert_match @user.followers.count.to_s, response.body
    @user.followers.each do |user|
      assert_select "a[href=?]", user_path(user)
    end
  end
  
  # ボタンのテスト。押下した場合、件数が変わっていることを確認。通常とAjaxどちらも確認
  
  test "should follow a user the standard way" do
    assert_difference '@user.following.count', 1 do
      post relationships_path, params: { followed_id: @other.id }
    end
  end
  
  # Ajax版確認 xhr:XmlHttpRequestをtrueにするとAjaxからリクエストを送れる
  test "should follow a user with Ajax" do
    assert_difference '@user.following.count', 1 do
      post relationships_path, xhr: true, params: { followed_id: @other.id }
    end
  end
  
  
  test "should unfollow a user the standard way" do
    @user.follow(@other)
    relationship = @user.active_relationships.find_by(followed_id: @other.id)
    assert_difference '@user.following.count', -1 do
      delete relationship_path(relationship)
    end
  end
  
  test "should unfollow a user with Ajax" do
    @user.follow(@other)
    relationship = @user.active_relationships.find_by(followed_id: @other.id)
    assert_difference '@user.following.count', -1 do
      delete relationship_path(relationship), xhr: true
    end
  end
  
  
  # test "the truth" do
  #   assert true
  # end
end
