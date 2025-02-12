require 'rails_helper'

RSpec.describe Order, type: :model do
  let(:customer) { double('Customer', id: 1, name: 'John Wick', address: '123 Main St') }

  it 'is valid with valid attributes' do
    order = build(:order, customer_id: customer.id)
    expect(order).to be_valid
  end

  it 'belongs to a customer' do
    order = build(:order, customer_id: customer.id)
    expect(order.customer_id).to eq(1)
  end

  it 'is not valid without a customer_id' do
    order = build(:order, customer_id: nil, customer_details: {})
    expect(order).to_not be_valid
  end

  it 'is not valid without a product name' do
    order = build(:order, customer_id: customer.id, product_name: nil)
    expect(order).to_not be_valid
  end

  it 'is not valid without a quantity' do
    order = build(:order, customer_id: customer.id, quantity: nil)
    expect(order).to_not be_valid
  end

  it 'is not valid without a price' do
    order = build(:order, customer_id: customer.id, price: nil)
    expect(order).to_not be_valid
  end

  it 'is not valid without a status' do
    order = build(:order, customer_id: customer.id, status: nil)
    expect(order).to_not be_valid
  end

  it 'is not valid without a customer_details' do
    order = build(:order, customer_id: customer.id, customer_details: {})
    expect(order).to_not be_valid
  end

  describe 'callbacks' do
    it 'calls publish_order_created_event after creating an order' do
      allow(OrderEventPublisher).to receive(:publish)
      valid_attributes = build(:order, customer_id: customer.id).attributes
      order = Order.create(valid_attributes)

      expect(OrderEventPublisher).to have_received(:publish).with(order)
    end
  end
end
