class CustomersController < ApplicationController
  before_action :set_customer, only: [:show]

  def show
    render json: @customer, status: :ok
  end

  private

  def set_customer
    @customer ||= Customer.find(params[:customer_id])
  rescue ActiveRecord::RecordNotFound
    render json: { error: "Customer not found" }, status: :not_found 
    return
  end
end
