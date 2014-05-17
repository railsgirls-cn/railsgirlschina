class Settings::ProfilesController < Settings::ApplicationController
  def show
  end

  def update
    if @user.update_attributes params.require(:user).permit(:name, :bio, :avatar, :remove_avatar)
      if params[:user][:city]
        city = City.find_or_create_by(name: params[:user][:city])
        @user.city = city
        @user.save!
      end
      flash[:success] = I18n.t('settings.profiles.flashes.successfully_updated')
      redirect_to settings_profile_url
    else
      render :show
    end
  end
end
