class UsersController < ApplicationController
  before_action :logged_in_user,only: [:edit,:update,:index]
  before_action :correct_user,only: [:edit,:update]

  def index
    @users = User.paginate(page:(params[:page]))
  end

  def new
    @user = User.new
  end

  def show
    @user = User.find(params[:id])
  end

  def create
    @user = User.new(user_params)
    if @user.save
      #保存の成功
      log_in @user
      flash[:success] = "Welcome to Sample App!"
      redirect_to @user
    else
      render 'new'
    end
  end

  def edit
    @user = User.find(params[:id])
  end

  def update
    @user = User.find(params[:id])
    if @user.update(user_params)
      #更新に成功した場合の処理
      flash[:success] = "Profile updated"
      redirect_to @user
    else
      render 'edit'
    end
  end

  private 
    #ストロングパラメータ、マスアサインメントの脆弱性対策
    #そもそも、マスアサインメントとは、DBの更新処理で複数からむ同時に指定することである。
    def user_params
      params.require(:user).permit(:name,:email,:password,:password_confirmation)
    end

    #beforeアクション

    #ログイン済みユーザか確認
    def logged_in_user
      unless logged_in?
        store_location
        flash[:danger] = 'Please log in...'
        redirect_to login_url
      end
    end

    #正しいユーザーかどうか確認
    def correct_user
      @user = User.find(params[:id])
      redirect_to(root_url) unless current_user?(@user)
    end
end
