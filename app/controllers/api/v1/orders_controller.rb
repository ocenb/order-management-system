module Api
  module V1
    class OrdersController < BaseController
      def create
        result = Orders::CreateFromApi.call(order_create_params.to_h)
        status = result.created ? :created : :ok

        render json: {
          order_id: result.order.id,
          status: result.order.status
        }, status:
      rescue ActionController::ParameterMissing => e
        render json: { error: e.message }, status: :unprocessable_entity
      rescue ActiveRecord::RecordInvalid => e
        render json: { error: e.record.errors.full_messages.to_sentence }, status: :unprocessable_entity
      end

      def show
        order = Order.find(params[:id])

        render json: {
          order_id: order.id,
          source: order.source,
          external_id: order.external_id,
          status: order.status
        }
      rescue ActiveRecord::RecordNotFound
        render json: { error: "Order not found" }, status: :not_found
      end

      private

      def order_create_params
        params.require(:order).permit(
          :source,
          :external_id,
          :customer_email,
          :customer_name,
          :delivery_address,
          :total_amount,
          :currency,
          items: %i[sku name quantity price]
        )
      end
    end
  end
end
