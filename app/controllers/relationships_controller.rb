class RelationshipsController < ApplicationController
  before_action :logged_in_user
  
  def create
    @user = User.find(params[:followed_id])
    current_user.follow(@user)
    # redirect_to user
    # Ajax対応 非同期のための処理を実施 下記文はif文に近いイメージ。どちらかが実行される
    respond_to do |format|
      format.html { redirect_to @user }
      format.js
    end
  end
  
  def destroy
    @user = Relationship.find(params[:id]).followed
    current_user.unfollow(@user)
    # Ajax対応 非同期のための処理を実施 下記文はif文に近いイメージ。どちらかが実行される
    respond_to do |format|
      format.html { redirect_to @user }
      format.js
    end
  end
  
end
