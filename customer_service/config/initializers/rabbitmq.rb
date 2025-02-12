# config/initializers/rabbitmq.rb
require 'bunny'

QUEUE_NAME = 'order_created'.freeze

connection_params = {
  host: ENV.fetch('RABBITMQ_HOST', 'rabbitmq'), # Usamos el nombre del servicio de Docker
  port: ENV.fetch('RABBITMQ_PORT', '5672'),     # Puerto por defecto
  user: ENV.fetch('RABBITMQ_USER', 'guest'),    # Usuario por defecto
  password: ENV.fetch('RABBITMQ_PASSWORD', 'guest'),  # Contraseña por defecto
  vhost: ENV.fetch('RABBITMQ_VHOST', '/')
}

begin
    connection = Bunny.new(connection_params)
    connection.start

    # channel = connection.create_channel
    # order_queue = channel.queue(QUEUE_NAME, durable: true)

    Rails.application.config.rabbitmq = { 
        connection: connection, 
        channel: connection.create_channel, 
        order_queue: connection.create_channel.queue(QUEUE_NAME, durable: true) # Creamos una nueva cola para order_queue
    }
rescue Bunny::Exception => e
    Rails.logger.error "RabbitMQ connection error: #{e.message}"
    retry
end