Rails.application.routes.draw do
  get 'password_resets/new'
  get 'password_resets/edit'
  # 自動的に追加される下記行をコメントアウト
  # get 'sessions/new'
  
  # get 'users/new'
  # root 'application#hello'
  root 'static_pages#home'
  
    # 名前付きパスは変数名を変更できる to:00, as:00
  # get '/help',    to: 'static_pages#help',as:'helf'
  get '/help',    to: 'static_pages#help'
  get '/about',   to: 'static_pages#about'
  get '/contact', to: 'static_pages#contact'
  
  # user
  get '/signup',   to: 'users#new'
  
  # 下記消すとエラーになると描いてあったが本当？
  # post 'signup',   to: 'users#create'
  
  # login
  get     '/login',  to: 'sessions#new'
  post    '/login',  to: 'sessions#create'
  delete  'logout',  to: 'sessions#destroy'
  
  # follower,following件数
  # /users/1/following や /users/1/followers どちらもgetメソッドなのでこの記載方法
  # memberを使うとuser_idが含まれるURL,collectionを使うとidを指定せずにすべてを表示する
  resources :users do
    member do
      get :following, :followers
    end
  end
  
  # users/1のようなURL(ルーティング)を有効にする
  resources :users
  
  # 名前付きルートが使えるように、またeditのみ使えるようにする
  resources :account_activations, only: [:edit]
  
  # 名前付きルートが使えるように
  resources :password_resets,     only:[:new, :create, :edit, :update]
  
  # 名前付きルートが使えるように 新規作成と削除のみ
  resources :microposts,          only:[:create, :destroy]
  
  # 名前付きルートが使えるように
  resources :relationships,       only:[:create, :destroy]
  
  #get 'static_pages/home'
  #get 'static_pages/help'
  #get 'static_pages/about'
  #get 'static_pages/contact'
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
  
end
