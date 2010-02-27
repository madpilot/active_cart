require 'test_helper'

class ActsAsCartTest < ActiveSupport::TestCase
  context '' do
    setup do
      @cart = Cart.make
    end
  
    context 'cart storage' do
      should 'acts as a array' do
        item = CartItem.make_unsaved(:cart => nil, :quantity => 1)
        assert_nothing_raised do
          @cart << item
        end
        
        @cart.save!
        assert_equal 1, @cart.size
        assert_equal 1, @cart.quantity
        assert_equal item, @cart[0]
      end
    end
  end
end
