class AddCustomerDetailsToOrders < ActiveRecord::Migration[7.2]
  def change
    add_column :orders, :customer_details, :jsonb, null: false, default: {}
    add_index :orders, :customer_details, using: :gin
  end
end
