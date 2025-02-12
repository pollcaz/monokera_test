class Customer < ApplicationRecord
    validates :name, :address, presence: true
    validates :orders_count, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
end
