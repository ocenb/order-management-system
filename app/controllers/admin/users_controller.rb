module Admin
  class UsersController < BaseController
    before_action :set_user, only: :update

    def index
      authorize User
      @users = policy_scope(User).order(:email)
    end

    def update
      authorize @user

      @user.role = user_role_param

      if @user.save
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

    def user_role_param
      role = params.require(:user).fetch(:role)
      User::ROLES.value?(role) ? role : nil
    end
  end
end
