class OrderEventPublisher
    def self.publish(order, queue_name = nil)
        channel = Rails.application.config.rabbitmq[:channel]
        order_queue = if queue_name
                        channel.queue(queue_name, durable: true)
                      else
                        Rails.application.config.rabbitmq[:order_queue]
                      end
        message = { customer_id: order.customer_id }
        order_queue.publish(message.to_json, persistent: true)
        Rails.logger.info "RabbitMQ send a message successfully: order: #{order.id}, message: #{message}"
    rescue Bunny::Exception => e
        Rails.logger.error "RabbitMQ error: #{e.message}"
        raise e
    end
  end
