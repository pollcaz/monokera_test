require 'rails_helper'

RSpec.describe CustomerService, type: :service do
  describe '.get_customer' do
    let(:customer_id) { 123 }
    let(:customer_data) { { "id" => customer_id, "name" => "John Wick", address: "123 Main St" }.to_json }

    before do
      stub_request(:get, "http://customer_service:3000/customers/#{customer_id}")
        .to_return(status: 200, body: customer_data, headers: { 'Content-Type' => 'application/json' })
    end

    context 'when the customer is found' do
      it 'returns customer data as a parsed JSON' do
        response = CustomerService.get_customer(customer_id)

        expect(response).to be_a(Hash)
        expect(response["id"]).to eq(customer_id)
        expect(response["name"]).to eq("John Wick")
        expect(response["address"]).to eq("123 Main St")
      end
    end

    context 'when the customer is not found' do
      before do
        stub_request(:get, "http://customer_service:3000/customers/#{customer_id}")
          .to_return(status: 404, body: '', headers: {})
      end

      it 'raises a CustomerNotFoundError' do
        expect { CustomerService.get_customer(customer_id) }
          .to raise_error(CustomerService::CustomerNotFoundError, "Customer not found")
      end
    end
  end
end
