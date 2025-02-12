require 'rails_helper'

RSpec.describe "Customers", type: :request do
  describe "GET /show" do
    context 'when the customer exists' do
      let(:customer) { create(:customer) }

      it "returns http success" do
        get "/customers/#{customer.id}"
        expect(response).to have_http_status(:success)
      end
    end

    context 'when the customer does not exist' do
      it "returns http not found" do
        get "/customers/99999"
        expect(response).to have_http_status(:not_found)
      end
    end
  end
end
