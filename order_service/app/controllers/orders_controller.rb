 class OrdersController < ApplicationController
  before_action :validate_create_params, only: [:create]
  before_action :validate_index_params, only: [:index]

  def create
    Rails.logger.info "Received order creation request: #{order_params}"
    result_object = OrderCreatorService.new(order_params).call
    status = result_object.success ? :created : :unprocessable_entity

    render json: result_object, status: status
  rescue StandardError => e
    render json: { error: "Internal Server Error: #{e.message}" }, status: :internal_server_error  
  end

  def index
    orders = Order.where(customer_id: params[:customer_id])
    render json: orders
  end

  private

  def order_params
    params.permit(:customer_id, :product_name, :quantity, :price, :status)
  end

  def validate_create_params
    required_params = %w[customer_id product_name quantity price status]

    missing_params = required_params.select { |param| params[param].blank? }
    if missing_params.any?
      render json: { error: "Missing parameters: #{missing_params.join(', ')}" }, status: :unprocessable_entity
    end
  end

  def validate_index_params
    if params[:customer_id].blank?
      render json: { error: "Missing parameter: customer_id is required" }, status: :unprocessable_entity
      return
    end
  end
end
