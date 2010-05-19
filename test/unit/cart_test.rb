require 'test_helper'

class CartTest < ActiveSupport::TestCase
  context '' do
    context 'after setup' do
      setup do
        @cart_storage_engine = TestCartStorage.new
        @cart = ActiveCart::Cart.new(@cart_storage_engine)
      end

      context 'update_cart' do
        should 'update the number of items in the cart if the item is in the cart' do
          item = TestItem.new(1)
          @cart.add_to_cart(item, 10)
          assert_equal 1, @cart.size
          assert_equal 10, @cart.quantity

          @cart.update_cart(item, 20)
          assert_equal 1, @cart.size
          assert_equal 20, @cart.quantity
        end

        should 'set the given quantity of items in to the cart if the item is not yet in the cart' do
          item = TestItem.new(1)
          
          @cart.update_cart(item, 20)
          assert_equal 1, @cart.size
          assert_equal 20, @cart.quantity
        end

        should 'set the given quantity of item in to the cart if the requested value is lower than the current quantity' do
          item = TestItem.new(1)

          @cart.add_to_cart(item, 10)
          assert_equal 1, @cart.size
          assert_equal 10, @cart.quantity

          @cart.update_cart(item, 4)
          assert_equal 1, @cart.size
          assert_equal 4, @cart.quantity
        end
      end

      context 'callbacks' do
        context 'items' do
          should 'fire the item before_add_to_cart callback on add to cart' do
            item = TestItem.new
            item.expects(:before_add_to_cart).with(1, {}).returns(true)
            @cart.add_to_cart(item, 1)
            assert_equal 1, @cart.quantity
          end

          should 'halt and return false if before_add_to_cart returns false' do
            item = TestItem.new
            item.expects(:before_add_to_cart).with(1, { :option => 'value' }).returns(false)
            assert !@cart.add_to_cart(item, 1, { :option => 'value' })
            assert_equal 0, @cart.quantity
          end

          should 'fire the item after_add_to_cart callback' do
            item = TestItem.new
            item.expects(:after_add_to_cart).with(1, { :option => 'value' })
            @cart.add_to_cart(item, 1, { :option => 'value' })
          end

          should 'fire the item before_remove_from_cart callback on add to cart' do
            item = TestItem.new
            item.expects(:before_remove_from_cart).with(1, { :option => 'value' }).returns(true)
            @cart.remove_from_cart(item, 1, { :option => 'value' })
            assert_equal 0, @cart.quantity
          end

          should 'halt and return false if beforee_add_to_cart returns false' do
            item = TestItem.new
            @cart.add_to_cart(item, 1)
            assert_equal 1, @cart.quantity
            item.expects(:before_remove_from_cart).with(1, {}).returns(false)
            assert !@cart.remove_from_cart(item, 1)
            assert_equal 1, @cart.quantity
          end

          should 'fire the item after_remove_from_cart callback' do
            item = TestItem.new
            item.expects(:after_remove_from_cart).with(1, { :option => 'value' })
            @cart.remove_from_cart(item, 1, { :option => 'value' })
          end

          should 'fire the item before_add_to_cart callback if update_cart adds items to the cart' do
            item = TestItem.new
            @cart.add_to_cart(item, 10)
            item.expects(:before_add_to_cart).with(10, {}).returns(true)
            @cart.update_cart(item, 20)
            assert 20, @cart.quantity
          end

          should 'halt and return false if before_add_to_cart callback returns fale when update_cart adds items to the cart' do
            item = TestItem.new
            @cart.add_to_cart(item, 10)
            item.expects(:before_add_to_cart).with(10, { :option => 'value' }).returns(false)
            assert !@cart.update_cart(item, 20, { :option => 'value' })
            assert 10, @cart.quantity
          end

          should 'fire the item after_add_to_cart callback if update_cart adds items to the cart' do
            item = TestItem.new
            @cart.add_to_cart(item, 10)
            item.expects(:after_add_to_cart).with(10, {}).returns(true)
            @cart.update_cart(item, 20)
            assert 20, @cart.quantity
          end

           should 'fire the item after_remove_from_cart callback if update_cart removes items from the cart' do
            item = TestItem.new
            @cart.add_to_cart(item, 10)
            item.expects(:before_remove_from_cart).with(5, {}).returns(true)
            @cart.update_cart(item, 5)
            assert 5, @cart.quantity
          end

          should 'halt and return false if after_remove_from_cart callback returns false when update_cart removes items from the cart' do
            item = TestItem.new
            @cart.add_to_cart(item, 10)
            item.expects(:before_remove_from_cart).with(5, { :option => 'value' }).returns(false)
            assert !@cart.update_cart(item, 5, { :option => 'value' })
            assert 10, @cart.quantity
          end


          should 'fire the item after_remove_from_cart callback if update_cart adds items to the cart' do
            item = TestItem.new
            @cart.add_to_cart(item, 10)
            item.expects(:after_remove_from_cart).with(5, {}).returns(true)
            @cart.update_cart(item, 5)
            assert 10, @cart.quantity
          end
        end

        context 'storage engines' do
          should 'fire the storage engines before_add_to_cart callback on add to cart' do
            item = TestItem.new
            @cart_storage_engine.expects(:before_add_to_cart).with(item, 1, { :option => 'value' }).returns(true)
            @cart.add_to_cart(item, 1, { :option => 'value' })
            assert_equal 1, @cart.quantity
          end

          should 'halt and return false if before_add_to_cart returns false' do
            item = TestItem.new
            @cart_storage_engine.expects(:before_add_to_cart).with(item, 1,  { :option => 'value' }).returns(false)
            assert !@cart.add_to_cart(item, 1, { :option => 'value' })
            assert_equal 0, @cart.quantity
          end

          should 'fire the storage engines after_add_to_cart callback' do
            item = TestItem.new
            @cart_storage_engine.expects(:after_add_to_cart).with(item, 1, {})
            @cart.add_to_cart(item, 1)
          end

          should 'fire the storage engines before_remove_from_cart callback on add to cart' do
            item = TestItem.new
            @cart_storage_engine.expects(:before_remove_from_cart).with(item, 1, {}).returns(true)
            @cart.remove_from_cart(item, 1)
            assert_equal 0, @cart.quantity
          end

          should 'halt and return false if beforee_add_to_cart returns false' do
            item = TestItem.new
            @cart.add_to_cart(item, 1)
            assert_equal 1, @cart.quantity
            @cart_storage_engine.expects(:before_remove_from_cart).with(item, 1,  { :option => 'value' }).returns(false)
            assert !@cart.remove_from_cart(item, 1, { :option => 'value' })
            assert_equal 1, @cart.quantity
          end

          should 'fire the storage engines after_remove_from_cart callback' do
            item = TestItem.new
            @cart_storage_engine.expects(:after_remove_from_cart).with(item, 1,  { :option => 'value' })
            @cart.remove_from_cart(item, 1, { :option => 'value' })
          end
        end
      end

      context 'delegate to cart storage' do
        should 'delegate []' do
          @cart_storage_engine.expects(:[]).with(0)
          @cart[0]
        end

        should 'delegate <<' do
          test = TestItem.new
          @cart_storage_engine.expects(:<<).with(test)
          @cart << test
        end

        should 'delegate []=' do
          test = TestItem.new
          @cart_storage_engine.expects(:[]=).with(0, test)
          @cart[0] = test
        end

        should 'delegate :at' do
          @cart_storage_engine.expects(:at).with(1)
          @cart.at(1)
        end

        should 'delegate :clear' do
          @cart_storage_engine.expects(:clear)
          @cart.clear
        end

        should 'delegate :collect' do
          @cart_storage_engine.expects(:collect)
          @cart.collect
        end

        should 'delegate :map' do
          @cart_storage_engine.expects(:map)
          @cart.map
        end

        should 'delegate :delete' do
          test = TestItem.new
          @cart_storage_engine.expects(:delete).with(test)
          @cart.delete(test)
        end

        should 'delegate :delete_at' do
          @cart_storage_engine.expects(:delete_at).with(3)
          @cart.delete_at(3)
        end

        should 'delegate :each' do
          @cart_storage_engine.expects(:each)
          @cart.each
        end

        should 'delegate :each_index' do
          @cart_storage_engine.expects(:each_index)
          @cart.each_index
        end

        should 'delegate :empty' do
          @cart_storage_engine.expects(:empty?)
          @cart.empty?
        end

        should 'delegate :eql?' do
          @cart_storage_engine.expects(:eql?)
          @cart.eql?
        end

        should 'delegate :first' do
          @cart_storage_engine.expects(:first)
          @cart.first
        end

        should 'delegate :include?' do
          @cart_storage_engine.expects(:include?)
          @cart.include?
        end

        should 'delegate :index' do
          @cart_storage_engine.expects(:index)
          @cart.index
        end

        should 'delegate :inject' do
          @cart_storage_engine.expects(:inject)
          @cart.inject
        end

        should 'delegate :last' do
          @cart_storage_engine.expects(:last)
          @cart.last
        end

        should 'delegate :length' do
          @cart_storage_engine.expects(:length)
          @cart.length
        end

        should 'delegate :pop' do
          @cart_storage_engine.expects(:pop)
          @cart.pop
        end

        should 'delegate :push' do
          @cart_storage_engine.expects(:push)
          @cart.push
        end

        should 'delegate :shift' do
          @cart_storage_engine.expects(:shift)
          @cart.shift
        end

        should 'delegate :size' do
          @cart_storage_engine.expects(:size)
          @cart.size
        end

        should 'delegate :unshift' do
          @cart_storage_engine.expects(:unshift)
          @cart.unshift
        end

        should 'delegate :invoice_id' do
          @cart_storage_engine.expects(:invoice_id)
          @cart.invoice_id
        end

        should 'delegate :sub_total' do
          @cart_storage_engine.expects(:sub_total)
          @cart.sub_total
        end

        should 'delegate :state' do
          @cart_storage_engine.expects(:state).returns(:shopping)
          @cart.state
        end
        
        should 'delegate :continue_shopping!' do
          @cart_storage_engine.expects(:continue_shopping!)
          @cart.continue_shopping!
        end
        
        should 'delegate :checkout!' do
          @cart_storage_engine.expects(:checkout!)
          @cart.checkout!
        end
        
        should 'delegate :check_payment!' do
          @cart_storage_engine.expects(:check_payment!)
          @cart.check_payment!
        end
        
        should 'delegate :payment_successful!' do
          @cart_storage_engine.expects(:payment_successful!)
          @cart.payment_successful!
        end
        
        should 'delegate :payment_failed!' do
          @cart_storage_engine.expects(:payment_failed!)
          @cart.payment_failed!
        end
      end

      context 'setup' do
        should 'take a block to add order_totals' do
          @total_1 = TestOrderTotal.new('Total 1', 10, true)
          @total_2 = TestOrderTotal.new('Total 2', 20, true)
          
          @cart_storage_engine = TestCartStorage.new
          @cart = ActiveCart::Cart.new(@cart_storage_engine) do |o|
            o << @total_1
            o << @total_2
          end
          assert_equal [ @total_1, @total_2 ], @cart.order_total_calculators
        end
      end

      context 'total' do
        should 'sum all the items in the cart with order totals' do
          @item_1 = TestItem.new(1)
          @item_1.price = 10
          @item_2 = TestItem.new(2)
          @item_2.price = 20
          @item_3 = TestItem.new(3)
          @item_3.price = 30
          @total_1 = TestOrderTotal.new('Total 1', 10, true)
          @total_2 = TestOrderTotal.new('Total 2', 20, true)

          @cart.order_total_calculators += [ @total_1, @total_2 ]
          @cart.add_to_cart(@item_1)
          @cart.add_to_cart(@item_2)
          @cart.add_to_cart(@item_3)

          assert_equal 90, @cart.total
        end
      end
    end
  end
end 
