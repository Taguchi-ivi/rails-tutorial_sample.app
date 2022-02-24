class MicropostsController < ApplicationController
  
  # beforeアクション application controllerで定義
  before_action :logged_in_user, only: [:create, :destroy]
  before_action :corrent_user,   only: :destroy
  
  
  def create
    @micropost = current_user.microposts.build(micropost_params)
    # 画像を追加
    @micropost.image.attach(params[:micropost][:image])
    
    if @micropost.save
      flash[:success] = "Micropost created!"
      redirect_to root_url
    else
      @feed_items = current_user.feed.paginate(page: params[:page])
      render 'static_pages/home'
    end
  end
  
  def destroy
    @micropost.destroy
    flash[:success] = "Micropost deleted"
    # 一つ前のURLを返す なかったらデフォルトの値としてroot_urlへ飛ぶ
    redirect_to request.referrer || root_url
  end
  
  private
    
    def micropost_params
      # params.require(:micropost).permit(:content)
      # 画像も許容する
      params.require(:micropost).permit(:content, :image)
    end
    
    # あるユーザーが他のユーザーのマイクロポストを削除しようとすると、自動的に失敗するように
    # 現在ユーザーが削除対象のマイクロポストを保有しているか判定 find_byで
    def corrent_user
      @micropost = current_user.microposts.find_by(id: params[:id])
      redirect_to root_url if @micropost.nil?
    end

end
