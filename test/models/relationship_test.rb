require 'test_helper'

class RelationshipTest < ActiveSupport::TestCase
  
  def setup
    @relationship = Relationship.new(follower_id: users(:michael).id,
                                     followed_id: users(:archer).id)
  end
  
  # バリデーションテスト 上記のsetupでエラーになっていないこと
  test "should be valid" do
    assert @relationship.valid?
  end
  
  # バリデーションテスト nilとした場合、エラーになることを確認
  test "should require a follower_id" do
    @relationship.follower_id = nil
    assert_not @relationship.valid?
  end
  
  # バリデーションテスト nilとした場合、エラーになることを確認
  test "should require a followed_id" do
    @relationship.followed_id = nil
    assert_not @relationship.valid?
  end
  
  # test "the truth" do
  #   assert true
  # end
end
