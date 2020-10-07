class UsersController < ApplicationController
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

end
