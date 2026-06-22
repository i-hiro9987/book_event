class SessionsController < ApplicationController
  def create
    auth = request.env['omniauth.auth']

    user = User.find_or_create_by!(provider: auth['provider'], uid: auth[:uid]) do |u|
      u.name = auth['info']['name'] || auth['info']['nickname']
      u.email = auth['info']['email']
    end

    session[:user_id] = user.id
    redirect_to root_path, notice: "#{user.name}さん、ようこそ！"
  end

  def destroy
    reset_session
    redirect_to root_path, notice: 'ログアウトしました'
  end

  def failure
    redirect_to root_path, alert: '認証に失敗しました'
  end
end
