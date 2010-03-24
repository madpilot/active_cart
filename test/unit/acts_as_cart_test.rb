require 'test_helper'

class ActsAsCartTest < ActiveSupport::TestCase
  context '' do
    setup do
      Cart.acts_as_cart
      @cart = Cart.make
    end

    context 'acts_as_cart' do
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

    context 'acts_as_cart_item' do
       context 'configuration' do
        should 'set defaults' do
          CartItem.acts_as_cart_item

          assert_equal :cart, CartItem.aaci_config[:cart]
          assert_equal :quantity , CartItem.aaci_config[:quantity_column]
          assert_equal :name , CartItem.aaci_config[:name_column]
          assert_equal :price , CartItem.aaci_config[:price_column]
        end

        context 'override' do
          should 'change quantity column' do
            CartItem.acts_as_cart_item :quantity_column => :dummy
            @cart = CartItem.make
            @cart.expects(:read_attribute).with(:dummy)
            @cart.quantity
          end

          should 'change name column' do
            CartItem.acts_as_cart_item :name_column => :dummy
            @cart = CartItem.make
            @cart.expects(:read_attribute).with(:dummy)
            @cart.name
          end
 
          should 'change price column' do
            CartItem.acts_as_cart_item :price_column => :dummy
            @cart = CartItem.make
            @cart.expects(:read_attribute).with(:dummy)
            @cart.price
          end
 
          should 'change cart_items' do
            CartItem.acts_as_cart_item :cart => :test

            assert_equal :test, CartItem.aaci_config[:cart]
            assert_equal :quantity , CartItem.aaci_config[:quantity_column]
            assert_equal :name , CartItem.aaci_config[:name_column]
            assert_equal :price , CartItem.aaci_config[:price_column]
          end

          should 'change the foreign_key' do
            CartItem.acts_as_cart_item :foreign_key => :test_id

            assert_equal :cart, CartItem.aaci_config[:cart]
            assert_equal :name , CartItem.aaci_config[:name_column]
            assert_equal :price , CartItem.aaci_config[:price_column]
            assert_equal :test_id, CartItem.aaci_config[:foreign_key]
          end
        end
      end
    end

    context 'new_from_item' do
      should 'copy all the relevent paramaters from the supplied item into a new cart item' do
        @item = Item.make
        @cart_item = CartItem.new_from_item(@item)
        assert @cart_item.valid?
        assert_equal @item.name, @cart_item.name
        assert_equal @item.price, @cart_item.price
        assert_equal @item, @cart_item.original
      end
    end


    context 'acts_as_order_total' do
       context 'configuration' do
        should 'set defaults' do
          OrderTotal.acts_as_order_total

          assert_equal :cart, OrderTotal.aaot_config[:cart]
          assert_equal :name , OrderTotal.aaot_config[:name_column]
          assert_equal :price , OrderTotal.aaot_config[:price_column]
          assert_equal :cart_id, OrderTotal.aaot_config[:foreign_key]
        end

        context 'override' do
          should 'change name column' do
            OrderTotal.acts_as_order_total :name_column => :dummy
            @order_total = OrderTotal.make
            @order_total.expects(:read_attribute).with(:dummy)
            @order_total.name
          end
 
          should 'change price column' do
            OrderTotal.acts_as_order_total :price_column => :dummy
            @order_total = OrderTotal.make
            @order_total.expects(:read_attribute).with(:dummy)
            @order_total.price
          end

          should 'change the foreign_key' do
             OrderTotal.acts_as_order_total :foreign_key => :test_id

            assert_equal :cart, OrderTotal.aaot_config[:cart]
            assert_equal :name , OrderTotal.aaot_config[:name_column]
            assert_equal :price , OrderTotal.aaot_config[:price_column]
            assert_equal :test_id, OrderTotal.aaot_config[:foreign_key]
          end
 
          should 'change cart_items' do
            OrderTotal.acts_as_order_total :cart => :test

            assert_equal :test, OrderTotal.aaot_config[:cart]
            assert_equal :name , OrderTotal.aaot_config[:name_column]
            assert_equal :price , OrderTotal.aaot_config[:price_column]
            assert_equal :test_id, OrderTotal.aaot_config[:foreign_key]
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
    end

    context 'add to cart' do
      should 'add an item to the cart if the cart is empty' do
        assert @cart.empty?
        item = Item.make
        @cart.add_to_cart(item)
        assert_equal 1, @cart.size
        assert_equal 1, @cart[0].quantity
        assert_equal 1, @cart.quantity
        assert_equal CartItem, @cart[0].class
        assert_equal item.id, @cart[0].original.id
      end

      should 'increase the item quantity if the same item is added to the cart again' do
        assert @cart.empty?
        item = Item.make
        @cart.add_to_cart(item)
        assert_equal 1, @cart.size
        assert_equal 1, @cart[0].quantity

        item_2 = Item.find(item.id) # Has the same id, is the same as item
        @cart.add_to_cart(item_2)
        assert_equal 1, @cart.size
        assert_equal 2, @cart[0].quantity
        assert_equal 2, @cart.quantity
        assert_equal CartItem, @cart[0].class
        assert_equal item.id, @cart[0].original.id
      end

      should 'increase the item quantity by the supplied number if the same item is add to the cart again and a quantity is supplied' do
        assert @cart.empty?
        item = Item.make
        @cart.add_to_cart(item)
        assert_equal 1, @cart.size
        assert_equal 1, @cart[0].quantity

        item_2 = Item.find(item.id) # Has the same id, is the same as item
        @cart.add_to_cart(item_2, 10)
        assert_equal 1, @cart.size
        assert_equal 11, @cart[0].quantity
        assert_equal 11, @cart.quantity
      end

      should 'add another item to the cart' do
        assert @cart.empty?
        item = Item.make
        @cart.add_to_cart(item)
        assert_equal 1, @cart.size
        assert_equal 1, @cart[0].quantity

        item_2 = Item.make
        @cart.add_to_cart(item_2, 10)
        assert_equal 2, @cart.size
        assert_equal 1, @cart[0].quantity
        assert_equal 10, @cart[1].quantity
        assert_equal 11, @cart.quantity
        assert_equal CartItem, @cart[0].class
        assert_equal item.id, @cart[0].original.id
        assert_equal CartItem, @cart[1].class
        assert_equal item_2.id, @cart[1].original.id
      end
    end

    context 'remove_from_cart' do
      should 'remove the quantity supplied from the cart' do
        item = Item.make
        @cart.add_to_cart(item, 10)
        assert_equal 1, @cart.size
        assert_equal 10, @cart.quantity

        @cart.remove_from_cart(item)
        assert_equal 1, @cart.size
        assert_equal 9, @cart.quantity
      end

      should 'remove the item from the cart if the quantity to be removed is equal to the number in cart' do
        item = Item.make
        @cart.add_to_cart(item, 10)
        assert_equal 1, @cart.size
        assert_equal 10, @cart.quantity

        @cart.remove_from_cart(item, 10)
        assert_equal 0, @cart.size
      end

      should 'remove the item from the cart if the quantity to be removed is greater than the number in cart' do
        item = Item.make
        @cart.add_to_cart(item, 10)
        assert_equal 1, @cart.size
        assert_equal 10, @cart.quantity

        @cart.remove_from_cart(item, 11)
        assert_equal 0, @cart.size

        assert_not_nil Item.find(item.id)
      end

      should "simply return if the item doesn't exist in the cart" do
        item = Item.make
        @cart.add_to_cart(item, 10)
        assert_equal 1, @cart.size
        assert_equal 10, @cart.quantity

        item_2 = Item.make
        @cart.remove_from_cart(item_2, 10)
        assert_equal 1, @cart.size
        assert_equal 10, @cart.quantity
      end
    end
  end
end
