require 'rails_helper'

RSpec.describe OrderEventPublisher, type: :event do
  let(:order) { double('Order', customer_id: 123, id: 1) }
  let(:channel) { double('Bunny::Channel') }
  let(:queue) { double('Bunny::Queue') }
  let(:message) { { customer_id: order.customer_id }.to_json }

  before do
    allow(Rails.application.config.rabbitmq).to receive(:[]).with(:channel).and_return(channel)
    allow(channel).to receive(:queue).and_return(queue)
    allow(queue).to receive(:publish)
  end

  describe '.publish' do
    context 'when a message is published successfully' do
      it 'publish the message to the specified queue' do
        expect(queue).to receive(:publish).with(message, persistent: true)

        OrderEventPublisher.publish(order, 'order_queue')
      end

      it 'uses the default queue if no queue name is provided' do
        default_queue = double('Bunny::Queue')
        allow(Rails.application.config.rabbitmq).to receive(:[]).with(:order_queue).and_return(default_queue)
        allow(default_queue).to receive(:publish)

        expect(default_queue).to receive(:publish).with(message, persistent: true)

        OrderEventPublisher.publish(order)
      end
    end

    context 'when there is a RabbitMQ error' do
      it 'logges the error and raises the exception' do
        allow(queue).to receive(:publish).and_raise(Bunny::Exception.new("RabbitMQ error"))

        expect(Rails.logger).to receive(:error).with(/RabbitMQ error/)
        expect { OrderEventPublisher.publish(order, 'order_queue') }.to raise_error(Bunny::Exception)
      end
    end
  end
end
