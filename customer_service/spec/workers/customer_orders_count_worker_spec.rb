require 'rails_helper'
require 'json'
require_relative '../../app/workers/customer_orders_count_worker'

RSpec.describe CustomerOrdersCountWorker, type: :worker do
  let(:mock_channel) { double('Bunny::Channel') }
  let(:mock_queue) { double('Bunny::Queue') }
  let(:worker) { CustomerOrdersCountWorker.new }
  let(:delivery_info) { double('delivery_info', delivery_tag: '123') }
  let!(:customer) { create(:customer, orders_count: 5) }
  let(:order_message) { { 'customer_id' => customer.id }.to_json }

  before do
    allow(Rails.application.config.rabbitmq).to receive(:[]).with(:channel).and_return(mock_channel)
    allow(Rails.application.config.rabbitmq).to receive(:[]).with(:order_queue).and_return(mock_queue)

    allow(Customer).to receive(:find_by).and_return(customer)
    allow(customer).to receive(:update).and_return(true)

    allow(mock_channel).to receive(:ack)
    allow(mock_channel).to receive(:reject)
  end

  describe '#start' do
    it 'acknowledges the message after processing successfully' do
        allow(mock_queue).to receive(:subscribe).with(block: true).and_yield(delivery_info, {}, order_message)
        expect(mock_channel).to receive(:ack).with('123')

        worker.start
    end

    it 'rejects the message if an error occurs (e.g., customer not found)' do
      allow(mock_queue).to receive(:subscribe).with(block: true).and_yield(delivery_info, {}, order_message)
      allow(Customer).to receive(:find_by).and_return(nil)

      expect(mock_channel).to receive(:reject).with('123', requeue: true)

      worker.start
    end
  end

  describe '#handle_message' do
    it 'increments the orders_count when customer is found' do
      worker.send(:handle_message, order_message)

      expect(customer.orders_count).to eq(6)
    end

    it 'raises an error if customer is not found' do
      allow(Customer).to receive(:find_by).and_return(nil)

      expect { worker.send(:handle_message, order_message) }.to raise_error(/Customer not found for order: \d+/)
    end
  end

  describe '#process_order' do
    it 'processes the order and updates the customer orders_count' do
      worker.send(:process_order, { 'customer_id' => customer.id })

      expect(customer.orders_count).to eq(6)
    end

    it 'raises an error when the customer is not found' do
      allow(Customer).to receive(:find_by).and_return(nil)

      expect { worker.send(:process_order, { 'customer_id' => 999 }) }.to raise_error("Customer not found for order: 999")
    end
  end
end
