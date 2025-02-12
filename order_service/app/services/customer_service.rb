class CustomerService
    BASE_URI = 'http://customer_service:3000'

    class CustomerNotFoundError < StandardError; end

    def self.get_customer(customer_id)      
      conn = Faraday.new(url: BASE_URI)
      response = conn.get("/customers/#{customer_id}")
      raise CustomerNotFoundError, "Customer not found" unless response.status == 200
      JSON.parse(response.body)
    rescue Faraday::Error => e
      Rails.logger.error "Error fetching customer details: #{e.message}"   
      raise e
    end
  end
