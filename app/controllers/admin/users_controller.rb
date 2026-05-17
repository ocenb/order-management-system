module Admin
  class UsersController < BaseController
    before_action :set_user, only: :update

    def index
      authorize User
      @users = policy_scope(User).order(:email)
    end

    def update
      authorize @user

      if @user.update(user_params)
        redirect_to admin_users_path, notice: "User updated."
      else
        @users = policy_scope(User).order(:email)
        render :index, status: :unprocessable_entity
      end
    end

    private

    def set_user
      @user = User.find(params[:id])
    end

    def user_params
      params.require(:user).permit(:role)
    end
  end
end
