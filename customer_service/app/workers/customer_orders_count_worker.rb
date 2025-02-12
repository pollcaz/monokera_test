require 'bunny'
require 'json'

class CustomerOrdersCountWorker
  def initialize
    @channel = Rails.application.config.rabbitmq[:channel]
    @queue = Rails.application.config.rabbitmq[:order_queue]
  end

  def start
    @queue.subscribe(block: true) do |delivery_info, _properties, body|
      begin
        handle_message(body)
        ack_message(delivery_info.delivery_tag)
        Rails.logger.info "Successfully processing message: #{JSON.parse(body)}"
      rescue => e
        Rails.logger.error "Error processing message: #{e.message}"
        puts "Error processing message: #{e.message}"
        reject_message(delivery_info.delivery_tag)
      end
    end
  end

  private

  def handle_message(body)
    order_message = JSON.parse(body)
    process_order(order_message)
  end

  def process_order(order_message)
    customer = Customer.find_by(id: order_message['customer_id'])
    raise "Customer not found for order: #{order_message['customer_id']}" unless customer
    customer.increment!(:orders_count)
    puts "Customer orders incremented to #{customer.orders_count} for customer: id: #{customer.id}, name: #{customer.name}"
    Rails.logger.info "Customer orders incremented to #{customer.orders_count} for customer: #{customer.name}"
  rescue => e
    puts "Failed to process increment orders_count: #{e.message}"
    raise e
  end

  def ack_message(delivery_tag)
    @channel.ack(delivery_tag)
  end

  def reject_message(delivery_tag)
    @channel.reject(delivery_tag, requeue: true)
  end
end
