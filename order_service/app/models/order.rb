class Order < ApplicationRecord
    validates :product_name, :quantity, :price, :status, :customer_id, :customer_details, presence: true
    validates :quantity, numericality: { greater_than: 0 }
    validates :price, numericality: { greater_or_equal_than: 0 }
    validate :customer_details_is_not_empty
    enum :status, { pending: 0, processing: 1, shipped: 2, completed: 3, cancelled: 4 }

    after_create :publish_order_created_event

    private
    def publish_order_created_event
        OrderEventPublisher.publish(self)
    end

    def customer_details_is_not_empty
        if customer_details.empty?
          errors.add(:customer_details, "can't be empty")
        end
    end
end
