class UsersController < ApplicationController
  before_action :logged_in_user,only: [:edit,:update,:index,:destroy,:following,:followers]
  before_action :correct_user,only: [:edit,:update]
  before_action :admin_user, only: :destroy

  def destroy
    User.find(params[:id]).destroy
    flash[:success] = "User Dleted"
    redirect_to users_url
  end

  def index
    @users = User.where(activated: true).paginate(page: params[:page])
  end

  def new
    @user = User.new
  end

  def show
    @user = User.find(params[:id])
    redirect_to root_url and return unless @user.activated?
    @microposts = @user.microposts.paginate(page: params[:page])
  end

  def create
    @user = User.new(user_params)
    if @user.save
      #保存の成功
      @user.send_activation_email
      flash[:info] = "Please check your email to activate your account"
      redirect_to root_url
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

  def following
    @title = "Following"
    @user = User.find(params[:id])
    @users = @user.following.paginate(page: params[:page])
    render 'show_follow'
  end

  def followers
    @title = "Followers"
    @user = User.find(params[:id])
    @users = @user.followers.paginate(page: params[:page])
    render 'show_follow'
  end

  private 
    #ストロングパラメータ、マスアサインメントの脆弱性対策
    #そもそも、マスアサインメントとは、DBの更新処理で複数からむ同時に指定することである。
    def user_params
      params.require(:user).permit(:name,:email,:password,:password_confirmation)
    end

    #beforeアクション

    #正しいユーザーかどうか確認
    def correct_user
      @user = User.find(params[:id])
      redirect_to(root_url) unless current_user?(@user)
    end

    #管理者かどうか確認
    def admin_user
      redirect_to(root_url) unless current_user.admin?
    end
end
