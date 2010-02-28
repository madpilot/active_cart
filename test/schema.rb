ActiveRecord::Schema.define :version => 0 do
  create_table :carts, :force => true do |t|
    t.string :invoice_id
    t.string :state
    t.string :dummy # Not needed in real carts - used sa a dummy field for testing
  end

  create_table :items, :force => true do |t|
    t.string :name
    t.float :price
  end

  create_table :cart_items, :force => true do |t|
    t.integer :cart_id
    t.string :name
    t.integer :quantity
    t.float :price
    t.integer :original_id
    t.string :original_type
    t.string :dummy # Not needed in real carts - used sa a dummy field for testing
  end

  create_table :order_totals, :force => true do |t|
    t.integer :cart_id
    t.string :name
    t.float :total
    t.string :dummy # Not needed in real carts - used sa a dummy field for testing
  end
end
