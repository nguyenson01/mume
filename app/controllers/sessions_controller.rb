class SessionsController < ApplicationController
	def new
  end

  def create
  	user = User.find_by_email(params[:session][:email].downcase)
    common_session_process(user)
  end

  def destroy
  	sign_out
    redirect_to root_url
  end

  def callback
    #omniauth.auth環境変数を取得
    auth = request.env["omniauth.auth"]

    #Userモデルを検索
    case auth["provider"]
    when "facebook" then
      user = User.find_by_provider_and_email(auth["provider"], auth["info"]["email"])
    else
      user = User.find_by_provider_and_nickname(auth["provider"], auth["info"]["nickname"])
    end

    # Userモデルに:providerと:uidが無い場合（外部認証していない）、保存してからルートへ遷移させる
    if user.nil? then user = User.create_with_omniauth(auth) end
      
    # Sign the user in and redirect to the user's show page.
    common_session_process(user)
  end

  private
    def common_session_process(user)
      if user && (user.authenticate(user.email) || user.authenticate(params[:session][:password]))
        # Sign the user in and redirect to the user's show page.
        sign_in user
        redirect_back_or user
      else
        # Create an error message and re-render the signin form.
        flash.now[:error] = 'Invalid email/password combination'
        render 'new'
      end
    end
end
