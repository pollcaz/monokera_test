FactoryBot.define do
  factory :customer do
    name { Faker::Name.unique.name }
    address { Faker::Address.full_address }
    orders_count { 0 }
  end
end
