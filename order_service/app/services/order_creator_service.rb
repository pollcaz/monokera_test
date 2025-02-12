require 'ostruct'

class OrderCreatorService
    class CustomerNotFoundError < StandardError; end

    def initialize(order_params)
      @order_params = order_params
    end

    def call
      customer = CustomerService.get_customer(@order_params['customer_id'])
      order = Order.new(@order_params.merge(customer_details: { name: customer['name'], address: customer['address'] }))
      order.save!
      OpenStruct.new(order: order, success: true)
    rescue Faraday::Error => e
      Rails.logger.error "Error fetching customer details: #{e.message}"
      raise CustomerNotFoundError, "Customer not found"
    rescue ActiveRecord::RecordInvalid => e
      Rails.logger.error "Error creating order: #{e.message}"
      OpenStruct.new(success: false, error: e.message)
    end
end
