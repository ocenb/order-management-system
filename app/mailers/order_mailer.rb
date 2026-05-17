class OrderMailer < ApplicationMailer
  def completed_email
    @order = params[:order]

    mail(
      to: @order.customer_email,
      subject: "Your order ##{@order.id} is completed"
    )
  end
end
