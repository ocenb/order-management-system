module Admin
  class OrdersController < BaseController
    before_action :set_order, only: %i[show edit update cancel destroy retry]

    def index
      authorize Order
      @orders = policy_scope(Order).order(created_at: :desc)
    end

    def show
      authorize @order
    end

    def edit
      authorize @order, :update?
    end

    def update
      authorize @order, :update?

      status = order_update_params[:status]
      attrs = order_update_params.except(:status)

      success = true

      success &&= @order.update(attrs) if attrs.present?
      @order.transition_to!(status, changed_by_user_id: current_user.id) if status.present? && status != @order.status

      if success
        redirect_to admin_order_path(@order), notice: "Order updated."
      else
        render :edit, status: :unprocessable_entity
      end
    rescue Order::InvalidStatusTransition => e
      @order.errors.add(:status, e.message)
      render :edit, status: :unprocessable_entity
    end

    def cancel
      authorize @order, :cancel?
      @order.transition_to!(:cancelled, changed_by_user_id: current_user.id, reason: params[:reason].presence)
      redirect_to admin_order_path(@order), notice: "Order cancelled."
    rescue Order::InvalidStatusTransition => e
      redirect_to admin_order_path(@order), alert: e.message
    end

    def retry
      authorize @order, :update?
      @order.retry_processing!
      redirect_to admin_order_path(@order), notice: "Order retry scheduled."
    rescue Order::InvalidStatusTransition => e
      redirect_to admin_order_path(@order), alert: e.message
    end

    def destroy
      authorize @order, :destroy?
      @order.update!(deleted_at: Time.current)
      redirect_to admin_orders_path, notice: "Order deleted."
    end

    private

    def set_order
      @order = Order.find(params[:id])
    end

    def order_update_params
      permitted = %i[status]
      permitted += %i[delivery_address] if current_user.manager? || current_user.admin?
      params.require(:order).permit(*permitted)
    end
  end
end
