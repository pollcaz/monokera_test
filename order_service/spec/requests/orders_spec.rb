require 'rails_helper'

RSpec.describe 'OrdersController', type: :request do
  let!(:customer) { double('Customer', id: 1, name: 'John Wick', address: '123 Main St') }
  let(:customer_details) { { name: customer.name, address: customer.address } }
  let(:customer_service_response) { { "id" => customer.id, "name" => customer.name, "address" => customer.address } }
  let!(:order) { create(:order, customer_id: customer.id, customer_details: customer_details) }
  let(:channel) { double('Bunny::Channel') }
  let(:queue) { double('Bunny::Queue') }
  let(:message) { { customer_id: order.customer_id }.to_json }

  before do
    allow(Rails.application.config.rabbitmq).to receive(:[]).with(:channel).and_return(channel)
    allow(channel).to receive(:queue).and_return(queue)
    allow(queue).to receive(:publish)
    allow(CustomerService).to receive(:get_customer).and_return(customer_service_response)
    allow(OrderEventPublisher).to receive(:publish)
  end

  describe 'POST /orders/create' do
    context 'when the request is valid' do
      let(:valid_params) { { customer_id: customer.id, product_name: 'Product 1', quantity: 1, price: 100.0, status: 'pending' } }

      it 'creates an order and returns status 201' do
        post '/orders', params: valid_params

        expect(response).to have_http_status(:created)
        res = JSON.parse(response.body)['table']
        expect(res['order']['customer_id']).to eq(customer.id)
        expect(res['order']['product_name']).to eq('Product 1')
      end
    end

    context 'when the request is invalid' do
      let(:invalid_params) { { customer_id: nil, product_name: '', quantity: -1, price: 0, status: '' } }

      it 'returns status 422' do
        post '/orders', params: invalid_params

        expect(response).to have_http_status(:unprocessable_entity)
        res = JSON.parse(response.body)

        expect(res['error']).to include('Missing parameters: customer_id, product_name, status')
      end
    end

    context 'when the request has invalid params values' do
      let(:invalid_params) { { customer_id: customer.id, product_name: 'Product 1', quantity: -1, price: 0, status: 'completed' } }

      it 'returns status 422' do
        post '/orders', params: invalid_params

        expect(response).to have_http_status(:unprocessable_entity)
        res = JSON.parse(response.body)['table']

        expect(res['error']).to include('Validation failed: Quantity must be greater than 0')
      end
    end
  end

  describe 'GET /orders/index' do
    context 'when the customer exists' do
      it 'returns a list of orders for the customer' do
        get "/orders?customer_id=#{customer.id}"

        expect(response).to have_http_status(:ok)
        res = JSON.parse(response.body)
        expect(res.length).to eq(1)
        expect(res.first['customer_id']).to eq(customer.id)
      end
    end

    context 'when the customer does not exist' do
      it 'returns an empty list of orders' do
        get "/orders?customer_id=99999"

        expect(response).to have_http_status(:ok)
        expect(JSON.parse(response.body)).to eq([])
      end
    end
  end
end
