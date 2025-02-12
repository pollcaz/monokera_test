FactoryBot.define do
  factory :order do
    product_name { "MyProduct" }
    quantity { 1 }
    price { 1.5 }
    status { 0 }
    customer_id { 1 }
    customer_details { {name: "John Wick", address: "123 Main St"} }
  end
end
