require 'test_helper'

class CartStorageTest < Test::Unit::TestCase
  context '' do
    setup do
      @cart_storage_engine = TestCartStorage.new
      @cart = ActiveCart::Cart.new(@cart_storage_engine)
    end

    context 'states' do
      context 'checkout' do
        should 'default to shopping' do
          assert_equal :shopping, @cart_storage_engine.state
        end

        should 'transition from shopping to checkout' do
          assert_nothing_raised do
            @cart_storage_engine.checkout!
          end
          assert_equal :checkout, @cart_storage_engine.state
        end

        should 'transition from checkout to check_payment' do
          @cart_storage_engine.checkout!
          assert_nothing_raised do
            @cart_storage_engine.check_payment!
          end
          assert_equal :verifying_payment, @cart_storage_engine.state
        end

        should 'transition from verifying_payment to completed' do
          @cart_storage_engine.checkout!
          @cart_storage_engine.check_payment!
          assert_nothing_raised do
            @cart_storage_engine.payment_successful!
          end
          assert_equal :completed, @cart_storage_engine.state
        end

        should 'transition from verifying_payment to shopping' do
          @cart_storage_engine.checkout!
          @cart_storage_engine.check_payment!
          assert_nothing_raised do
            @cart_storage_engine.continue_shopping!
          end
          assert_equal :shopping, @cart_storage_engine.state
        end

        should 'transition from verifying_payment to checkout' do
          @cart_storage_engine.checkout!
          @cart_storage_engine.check_payment!
          assert_nothing_raised do
            @cart_storage_engine.checkout!
          end
          assert_equal :checkout, @cart_storage_engine.state
        end

        should 'transition from verifying_payment to failed' do
          @cart_storage_engine.checkout!
          @cart_storage_engine.check_payment!
          assert_nothing_raised do
            @cart_storage_engine.payment_failed!
          end
          assert_equal :failed, @cart_storage_engine.state
        end
      end
    end

    context 'sub_total' do
      setup do
        @item_1 = TestItem.new(1)
        @item_2 = TestItem.new(2)
        @item_3 = TestItem.new(3)
        @item_1.price = 10
        @item_2.price = 12
        @item_3.price = 9
      end


      should 'return the price of a single item in the cart' do
        @cart.add_to_cart(@item_1)
        assert_equal 10, @cart.sub_total
      end

      should 'return the price of a single item with a quantity' do
        @cart.add_to_cart(@item_2, 3)
        assert_equal 36, @cart.sub_total
      end

      should 'return the sum of all the items in the cart' do
        @cart.add_to_cart(@item_1)
        @cart.add_to_cart(@item_2, 3)
        assert_equal 46, @cart.sub_total
      end
    end

    context 'add to cart' do
      should 'add an item to the cart if the cart is empty' do
        assert @cart.empty?
        item = TestItem.new
        @cart.add_to_cart(item)
        assert_equal 1, @cart.size
        assert_equal 1, @cart[0].quantity
        assert_equal 1, @cart.quantity
      end

      should 'increase the item quantity if the same item is added to the cart again' do
        assert @cart.empty?
        item = TestItem.new(1)
        @cart.add_to_cart(item)
        assert_equal 1, @cart.size
        assert_equal 1, @cart[0].quantity

        item_2 = TestItem.new(1) # Has the same id, is the same as item
        @cart.add_to_cart(item_2)
        assert_equal 1, @cart.size
        assert_equal 2, @cart[0].quantity
        assert_equal 2, @cart.quantity
      end

      should 'increase the item quantity by the supplied number if the same item is add to the cart again and a quantity is supplied' do
        assert @cart.empty?
        item = TestItem.new(1)
        @cart.add_to_cart(item)
        assert_equal 1, @cart.size
        assert_equal 1, @cart[0].quantity

        item_2 = TestItem.new(1) # Has the same id, is the same as item
        @cart.add_to_cart(item_2, 10)
        assert_equal 1, @cart.size
        assert_equal 11, @cart[0].quantity
        assert_equal 11, @cart.quantity
      end

      should 'add another item to the cart' do
        assert @cart.empty?
        item = TestItem.new(1)
        @cart.add_to_cart(item)
        assert_equal 1, @cart.size
        assert_equal 1, @cart[0].quantity

        item_2 = TestItem.new(2)
        @cart.add_to_cart(item_2, 10)
        assert_equal 2, @cart.size
        assert_equal 1, @cart[0].quantity
        assert_equal 10, @cart[1].quantity
        assert_equal 11, @cart.quantity
      end
    end

    context 'remove_from_cart' do
      should 'remove the quantity supplied from the cart' do
        item = TestItem.new(1)
        @cart.add_to_cart(item, 10)
        assert_equal 1, @cart.size
        assert_equal 10, @cart.quantity

        @cart.remove_from_cart(item)
        assert_equal 1, @cart.size
        assert_equal 9, @cart.quantity
      end

      should 'remove the item from the cart if the quantity to be removed is equal to the number in cart' do
        item = TestItem.new(1)
        @cart.add_to_cart(item, 10)
        assert_equal 1, @cart.size
        assert_equal 10, @cart.quantity

        @cart.remove_from_cart(item, 10)
        assert_equal 0, @cart.size
      end

      should 'remove the item from the cart if the quantity to be removed is greater than the number in cart' do
        item = TestItem.new(1)
        @cart.add_to_cart(item, 10)
        assert_equal 1, @cart.size
        assert_equal 10, @cart.quantity

        @cart.remove_from_cart(item, 11)
        assert_equal 0, @cart.size
      end

      should "simply return if the item doesn't exist in the cart" do
        item = TestItem.new(1)
        @cart.add_to_cart(item, 10)
        assert_equal 1, @cart.size
        assert_equal 10, @cart.quantity

        item_2 = TestItem.new(2)
        @cart.remove_from_cart(item_2, 10)
        assert_equal 1, @cart.size
        assert_equal 10, @cart.quantity
      end
    end
  end
end
