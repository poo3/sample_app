module SessionsHelper

  #渡されたユーザーでログインする
  def log_in(user)
    session[:user_id] = user.id
  end

  #ユーザーのセッションを永続的にする
  def remember(user)
    user.remember
    cookies.permanent.signed[:user_id] = user.id
    cookies.permanent[:remember_token] = user.remember_token
  end

  #現在ログイン中のユーザを返す
  def current_user
    if(user_id = session[:user_id])
      @current_user ||= User.find_by(id: user_id)
    elsif(user_id = cookies.signed[:user_id])
      user = User.find_by(id: user_id)
      if user && user.authenticated?(:remember,cookies[:remember_token])
        log_in user
        @current_user = user
      end
    end
  end

  #ユーザーがログインしていればtrue、その他ならばfalseを返します
  def logged_in?
    !current_user.nil?
  end

  #永続的セッションを破棄する
  def forget(user)
    user.forget
    cookies.delete(:user_id)
    cookies.delete(:remember_token)
  end

  #現在のユーザをログアウトする
  def log_out
    forget(current_user)
    session.delete(:user_id)
    @current_user = nil
  end

  #渡されたユーザがカレントユーザならtrueを返す
  def current_user?(user)
    user &. == current_user
  end
  
  #記憶したURL（もしくはデフォルト値へ）リダイレクト
  def redirect_back_or(default)
    redirect_to (session[:fowarding_url] || default)
    session.delete(:fowarding_url)
  end

  #アクセスしようとしたURLを覚えておく
  def store_location 
    session[:fowarding_url] = request.original_url if request.get?
  end
end
