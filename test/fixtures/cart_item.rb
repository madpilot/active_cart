class CartItem < ActiveRecord::Base
  acts_as_cart_item
  
  attr_accessor :options
end
