class SessionsController < Devise::SessionsController
  def new
    super
  end

  def create
    @user = User.new(user_params)
    if @user.ubs_no.start_with? 'o'
      if Ubs.login(@user)
        @user = User.find_by(ubs_no: @user.ubs_no)
        sign_in_and_redirect @user, event: :authentication
      else
        redirect_to clubs_path, alert: "Lutfen kullanıcı adınızı başındaki 'o' harfini yazarak giriniz."
      end
    elsif @user.ubs_no.length == 11
      @db_user = User.find_by(idnumber: @user.ubs_no)
      if @db_user.present?
        bcrypt   = BCrypt::Password.new(@db_user.encrypted_password)
        password = BCrypt::Engine.hash_secret("#{@user.password}#{resource.class.pepper}", bcrypt.salt)
        bcrypt.to_s == password.to_s ? (sign_in_and_redirect @db_user, event: :authentication) : (redirect_to clubs_path, alert: 'Girdiğiniz bilgiler hatalı. Lütfen tekrar deneyin.')
      else
        redirect_to clubs_path, alert: 'Girdiğiniz bilgiler hatalı. Lütfen tekrar deneyin.'
      end
    else
      redirect_to clubs_path, alert: 'Girdiğiniz bilgiler hatalı. Lütfen tekrar deneyin.'
    end
  end

  def destroy
    Devise.sign_out_all_scopes ? sign_out : sign_out(resource_name)
    redirect_to clubs_path, alert: 'Başarılı çıkış yaptınız'
  end

  private

  def user_params
    params.require(:user).permit(:ubs_no, :idnumber, :password)
  end
end
