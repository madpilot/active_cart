require 'test_helper'

class OrderTotalCollectionTest < Test::Unit::TestCase
  context '' do
    setup do
      @cart_storage_engine = TestCartStorage.new
      @cart = ActiveCart::Cart.setup(@cart_storage_engine)
      @collection = ActiveCart::OrderTotalCollection.new(@cart)
    end

    context 'insert_before' do
      should 'insert an object before the item at the supplied index' do
        @collection << '0'
        @collection << '1'
        @collection << '2'
        @collection << '3'
        @collection << '4'

        @collection.insert_before(3, '5')
        assert_equal [ '0', '1', '2', '5', '3', '4' ], @collection
      end

      should 'insert all the objects before the item at the supplied index' do
        @collection << '0'
        @collection << '1'
        @collection << '2'
        @collection << '3'
        @collection << '4'

        @collection.insert_before(3, '5', '6', '7', '8')
        assert_equal [ '0', '1', '2', '5', '6', '7', '8', '3', '4' ], @collection
      end

    end

    context 'insert_after' do
      should 'insert an object after the item at the supplied index' do
        @collection << '0'
        @collection << '1'
        @collection << '2'
        @collection << '3'
        @collection << '4'

        @collection.insert_after(3, '5')
        assert_equal [ '0', '1', '2', '3', '5', '4' ], @collection
      end

      should 'insert all the objects after the item at the supplied index' do
        @collection << '0'
        @collection << '1'
        @collection << '2'
        @collection << '3'
        @collection << '4'

        @collection.insert_after(3, '5', '6', '7', '8')
        assert_equal [ '0', '1', '2', '3', '5', '6', '7', '8', '4' ], @collection
      end
    end

    context 'move' do
      should 'move the item at the from index to the to index' do
        @collection << '0'
        @collection << '1'
        @collection << '2'
        @collection << '3'
        @collection << '4'

        @collection.move(3, 0)
        assert_equal [ '3', '0', '1', '2', '4' ], @collection
      end
    end

    context 'total' do
      setup do
        @total_1 = TestOrderTotal.new(10, true)
        @total_2 = TestOrderTotal.new(5, false)
        @total_3 = TestOrderTotal.new(2, true)
        @total_4 = TestOrderTotal.new(14, true)
      end

      should 'call price on each order_total item that are active' do
        @collection += [ @total_1, @total_2, @total_3, @total_4 ]
        assert_equal 26, @collection.total
      end
    end
  end
end
