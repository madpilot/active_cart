module ActiveCart
  # The Cart class is the core class in ActiveCart. It is a singleton (so you can only have one cart per application), that gets setup initially by passing in
  # a storage engine instance. Storage engines abstract away the storage of the cart, and is left as an exercise to the user. See the Storage engine docs
  # for details.
  #
  # The Cart class also takes order_total objects, which will calculate order totals. it may include thinkgs like shipping, or gift vouchers etc. See the Order Total
  # docs for details.
  #
  # The Cart object delegates a number of Array methods:
  # :[], :<<, :[]=, :at, :clear, :collect, :map, :delete, :delete_at, :each, :each_index, :empty?, :eql?, :first, :include?, :index, :inject, :last, :length, :pop, :push, :shift, :size, :unshift
  #
  class Cart
    attr_accessor :storage_engine, :order_total_calculators, :customer
    include Enumerable

    # The method MUST be called before you call instance, otherwise you will receive and StandardError
    # You need to supply a storage engine. An optional block can be given which allows you to add order total items.
    #
    # A typical initialization block might look like this
    #
    #   @cart = Cart.new(MyAwesomeStorageEngine.new) do |o|
    #     o << ShippingOrderTotal.new
    #     o << GstOrderTotal.new
    #   end
    #
    def initialize(storage_engine, &block)
      @storage_engine = storage_engine
      @order_total_calculators = OrderTotalCollection.new(self)

      if block_given?
        yield order_total_calculators
      end
    end

    extend Forwardable
    # Storage Engine Array delegators
    def_delegators :@storage_engine, :[], :<<, :[]=, :at, :clear, :collect, :map, :delete, :delete_at, :each, :each_index, :empty?, :eql?, :first, :include?, :index, :inject, :last, :length, :pop, :push, :shift, :size, :unshift
    
    # Returns a unique id for the invoice. It's upto the storage engine to generate and track these numbers
    #
    def invoice_id
      @storage_engine.invoice_id
    end

    # Returns the sub-total of all the items in the cart. Usually returns a float.
    #
    #   @cart.sub_total # => 100.00
    #
    def quantity
      @storage_engine.quantity
    end

    # Returns the subtotal of cart, which is effectively the total of all the items multiplied by their quantites. Does NOT include order_totals
    def sub_total
      @storage_engine.sub_total
    end

    # Adds an item to the cart. If the item already exists in the cart (identified by the id of the item), then the quantity will be increased but the supplied quantity (default: 1)
    #
    #   @cart.add_to_cart(item, 5)
    #   @cart.quantity # => 5
    #
    #   @cart.add_to_cart(item, 2)
    #   @cart.quantity # => 7
    #   @cart[0].size # => 7
    #   @cart[1] # => nil
    #
    #   @cart.add_to_cart(item_2, 4)
    #   @cart.quantity => 100
    #   @cart[0].size # => 7
    #   @cart[1].size # => 4
    #
    def add_to_cart(item, quantity = 1)
      @storage_engine.add_to_cart(item, quantity)
    end

    # Removes an item from the cart (identified by the id of the item). If the supplied quantity is greater than equal to the number in the cart, the item will be removed, otherwise the quantity will simply be decremented by the supplied amount
    #
    #   @cart.add_to_cart(item, 5)
    #   @cart[0].quantity # => 5
    #   @cart.remove_from_cart(item, 3)
    #   @cart[0].quantity # => 2
    #   @cart.remove_from_cart(item, 2)
    #   @cart[0] # => nil
    #
    def remove_from_cart(item, quantity = 1)
      @storage_engine.remove_from_cart(item, quantity)
    end
    
    # Returns the total of the cart. This includes all the order_total calculations
    #
    def total
      sub_total + order_total_calculators.total
    end
  end
end
