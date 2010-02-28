require 'test_helper'

class ActsAsCartTest < ActiveSupport::TestCase
  context '' do
    setup do
      Cart.acts_as_cart
      @cart = Cart.make
    end

    context 'configuration' do
      should 'set defaults' do
        Cart.expects(:aasm_column).with(:state)
        Cart.expects(:has_many).with(:cart_items)
        Cart.expects(:has_many).with(:order_totals)
       
        Cart.acts_as_cart

        assert_equal :state, Cart.aac_config[:state_column]
        assert_equal :invoice_id , Cart.aac_config[:invoice_id_column]
        assert_equal :cart_items , Cart.aac_config[:cart_items]
        assert_equal :order_totals , Cart.aac_config[:order_totals]
          
      end

      context 'override' do
        should 'change state' do
          Cart.expects(:aasm_column).with(:dummy)
          Cart.expects(:has_many).with(:cart_items)
          Cart.expects(:has_many).with(:order_totals)
          
          Cart.acts_as_cart :state_column => :dummy
          
          assert_equal :dummy, Cart.aac_config[:state_column]
          assert_equal :invoice_id , Cart.aac_config[:invoice_id_column]
          assert_equal :cart_items , Cart.aac_config[:cart_items]
          assert_equal :order_totals , Cart.aac_config[:order_totals]
        end

        should 'change state getter' do
          Cart.acts_as_cart :state_column => :dummy
          @cart = Cart.make
          @cart.expects(:read_attribute).with(:dummy).returns(:shopping)
          assert :shopping, @cart.state
        end

        should 'change invoice_id getter' do
          Cart.acts_as_cart :invoice_id_column => :dummy
          @cart = Cart.make
          @cart.expects(:read_attribute).with(:dummy)
          assert :shopping, @cart.invoice_id
        end
        
        should 'change cart_items' do
          Cart.expects(:aasm_column).with(:state)
          Cart.expects(:has_many).with(:test)
          Cart.expects(:has_many).with(:order_totals)
          
          Cart.acts_as_cart :cart_items => :test
          
          assert_equal :state, Cart.aac_config[:state_column]
          assert_equal :invoice_id , Cart.aac_config[:invoice_id_column]
          assert_equal :test , Cart.aac_config[:cart_items]
          assert_equal :order_totals , Cart.aac_config[:order_totals]
        end

        should 'change order_totals' do
          Cart.expects(:aasm_column).with(:state)
          Cart.expects(:has_many).with(:cart_items)
          Cart.expects(:has_many).with(:test)
          
          Cart.acts_as_cart :order_totals => :test
          
          assert_equal :state, Cart.aac_config[:state_column]
          assert_equal :invoice_id , Cart.aac_config[:invoice_id_column]
          assert_equal :cart_items , Cart.aac_config[:cart_items]
          assert_equal :test , Cart.aac_config[:order_totals]
        end
      end
    end

    context 'state' do
      should 'be persistent' do
        @cart.checkout!
        @cart.save!
        @cart = Cart.find(@cart.id)
        assert_equal 'checkout', @cart.state
        assert_nothing_raised do
          @cart.check_payment!
        end
      end
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

      context 'delegate to item' do
        setup do
          @cart << CartItem.make
          @cart.save!
        end

        should 'delegate []' do
          @cart.cart_items.expects(:[]).with(0)
          @cart[0]
        end

        should 'delegate <<' do
          test = CartItem.make
          @cart.cart_items.expects(:<<).with(test)
          @cart << test
        end

        should 'delegate []=' do
          test = CartItem.make
          @cart.cart_items.expects(:[]=).with(0, test)
          @cart[0] = test
        end

        should 'delegate :at' do
          @cart.cart_items.expects(:at).with(1)
          @cart.at(1)
        end

        should 'delegate :clear' do
          @cart.cart_items.expects(:clear)
          @cart.clear
        end

        should 'delegate :collect' do
          @cart.cart_items.expects(:collect)
          @cart.collect
        end

        should 'delegate :map' do
          @cart.cart_items.expects(:map)
          @cart.map
        end

        should 'delegate :delete' do
          test = CartItem.make
          @cart.cart_items.expects(:delete).with(test)
          @cart.delete(test)
        end

        should 'delegate :delete_at' do
          @cart.cart_items.expects(:delete_at).with(3)
          @cart.delete_at(3)
        end

        should 'delegate :each' do
          @cart.cart_items.expects(:each)
          @cart.each
        end

        should 'delegate :each_index' do
          @cart.cart_items.expects(:each_index)
          @cart.each_index
        end

        should 'delegate :empty' do
          @cart.cart_items.expects(:empty?)
          @cart.empty?
        end

        should 'delegate :eql?' do
          @cart.cart_items.expects(:eql?)
          @cart.eql?
        end

        should 'delegate :first' do
          @cart.cart_items.expects(:first)
          @cart.first
        end

        should 'delegate :include?' do
          item = CartItem.make
          @cart.cart_items.expects(:include?).with(CartItem.make)
          @cart.include?(item)
        end

        should 'delegate :index' do
          @cart.cart_items.expects(:index)
          @cart.index
        end

        should 'delegate :inject' do
          @cart.cart_items.expects(:inject)
          @cart.inject
        end

        should 'delegate :last' do
          @cart.cart_items.expects(:last)
          @cart.last
        end

        should 'delegate :length' do
          @cart.cart_items.expects(:length)
          @cart.length
        end

        should 'delegate :pop' do
          @cart.cart_items.expects(:pop)
          @cart.pop
        end

        should 'delegate :push' do
          item = CartItem.make
          @cart.cart_items.expects(:push).with(item)
          @cart.push(item)
        end

        should 'delegate :shift' do
          @cart.cart_items.expects(:shift)
          @cart.shift
        end

        should 'delegate :size' do
          @cart.cart_items.expects(:size)
          @cart.size
        end

        should 'delegate :unshift' do
          @cart.cart_items.expects(:unshift)
          @cart.unshift
        end
      end
    end
  end
end