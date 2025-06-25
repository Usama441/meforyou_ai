class ProfilesController < ApplicationController
  before_action :authenticate_user!

  def edit
    @user = current_user
  end

  def update
    if current_user.update(user_params)
      redirect_to root_path, notice: "Profile updated!"
    else
      render :edit
    end
  end

  private

  def user_params
    params.require(:user).permit(:name, :ai_name, :relationship)
  end
end
