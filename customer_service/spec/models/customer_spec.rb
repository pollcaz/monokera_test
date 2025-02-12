require 'rails_helper'

RSpec.describe Customer, type: :model do
  it "is valid with valid attributes" do
    customer = build(:customer)
    expect(customer).to be_valid
  end

  it "is invalid without a name" do
    customer = build(:customer, name: nil)
    expect(customer).not_to be_valid
    expect(customer.errors[:name]).to include("can't be blank")
  end

  it "is invalid without an address" do
    customer = build(:customer, address: nil)
    expect(customer).not_to be_valid
    expect(customer.errors[:address]).to include("can't be blank")
  end

  it "is invalid with a negative orders_count" do
    customer = build(:customer, orders_count: -1)
    expect(customer).not_to be_valid
    expect(customer.errors[:orders_count]).to include("must be greater than or equal to 0")
  end

  it "is invalid with a non-integer orders_count" do
    customer = build(:customer, orders_count: 2.5)
    expect(customer).not_to be_valid
    expect(customer.errors[:orders_count]).to include("must be an integer")
  end

  it "is valid with a zero orders_count" do
    customer = build(:customer, orders_count: 0)
    expect(customer).to be_valid
  end
end
