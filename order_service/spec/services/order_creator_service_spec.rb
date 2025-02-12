require 'rails_helper'

RSpec.describe OrderCreatorService, type: :service do
  let(:customer_id) { 123 }
  let(:order_params) { { customer_id: customer_id, product_name: "Laptop", quantity: 1, price: 1500, status: "completed" } }
  let(:customer_data) { { "id" => customer_id, "name" => "John Doe", "address" => "123 Main St" } }

  describe '#call' do
    context 'when the customer is found' do
      before do
        stub_request(:get, "http://customer_service:3000/customers/")
          .to_return(status: 200, body: customer_data.to_json, headers: { 'Content-Type' => 'application/json' })
        end

      it 'creates an order with the params sent and the customer_details data' do
        order_creator = OrderCreatorService.new(order_params)

        result = order_creator.call

        expect(result.order).to be_persisted
        expect(result.order.customer_details['name']).to eq(customer_data["name"])
        expect(result.order.customer_details['address']).to eq(customer_data["address"])
        expect(result.order.product_name).to eq(order_params[:product_name])
        expect(result.order.quantity).to eq(order_params[:quantity])
        expect(result.order.price).to eq(order_params[:price])
        expect(result.order.status).to eq(order_params[:status])
      end
    end

    context 'when the customer is not found' do
      before do
        stub_request(:get, "http://customer_service:3000/customers/")
          .to_return(status: 404, body: '', headers: {})
      end

      it 'raises a CustomerNotFoundError' do
        order_creator = OrderCreatorService.new(order_params)

        expect { order_creator.call }
          .to raise_error(CustomerService::CustomerNotFoundError, "Customer not found")
      end
    end

    context 'when there is a HTTP error when fetching the customer' do
      before do
        stub_request(:get, "http://customer_service:3000/customers/")
          .to_raise(Faraday::Error.new('Error fetching customer details'))
      end

      it 'logs the error and raises CustomerNotFoundError' do
        allow(Rails.logger).to receive(:error)
        order_creator = OrderCreatorService.new(order_params)

        expect { order_creator.call }.to raise_error(OrderCreatorService::CustomerNotFoundError, "Customer not found")
        expect(Rails.logger).to have_received(:error).with(/Error fetching customer details/).twice
      end
    end

    context 'when the active record validation triggers an error' do
        before do
          stub_request(:get, "http://customer_service:3000/customers/")
            .to_return(status: 200, body: customer_data.to_json, headers: { 'Content-Type' => 'application/json' })
          order_params['product_name'] = nil
        end

        it 'logs the error and returns an OpenStruct with success set to false' do
          order_creator = OrderCreatorService.new(order_params)

          expect(Rails.logger).to receive(:error).with(/Error creating order/)
          result = order_creator.call
          expect(result['success']).to eq(false)
          expect(result['error']).to include('Validation failed: Product name can\'t be blank')
        end
    end
  end
end
