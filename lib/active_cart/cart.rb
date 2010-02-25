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
  class Cart
    attr_accessor :storage_engine, :order_total_calculators, :customer
    include Singleton
    include Enumerable

    #nodoc
    def self.instance_with_setup_check
      raise StandardError, 'Please call setup first' unless @setup_called
      instance_without_setup_check
    end

    # The method MUST be called before you call instance, otherwise you will receive and StandardError
    # You need to supply a storage engine. An optional block can be given which allows you to add order total items.
    #
    # A typical initialization block might look like this
    #
    # @cart = Cart.setup(MyAwesomeStorageEngine.new) do |o|
    #   o << ShippingOrderTotal.new
    #   o << GstOrderTotal.new
    # end
    def self.setup(storage_engine, &block)
      @setup_called = true
      instance = self.instance_without_setup_check
      instance.storage_engine = storage_engine
      instance.order_total_calculators = OrderTotalCollection.new(self)

      if block_given?
        yield instance.order_total_calculators
      end
      instance
    end

    class << self
      alias_method :instance_without_setup_check, :instance
      alias_method :instance, :instance_with_setup_check
    end

    extend Forwardable
    # Storage Engine Array delegators
    def_delegators :@storage_engine, :[], :<<, :[]=, :at, :clear, :collect, :map, :delete, :delete_at, :each, :each_index, :empty?, :eql?, :first, :include?, :index, :inject, :last, :length, :pop, :push, :shift, :size, :unshift
    
    # Returns a unique id for the invoice. It's upto the storage engine to generate and track these numbers 
    def invoice_id
      @storage_engine.invoice_id
    end

    # Returns the number of items in the cart. Each different item in the cart may have different quantities, and this method will return the sum of that.
    # For example if the first item has a quantity of 2 and the second has a quantity of 3, this method will return 5
    def quantity
      @storage_engine.quantity
    end

    # Returns the subtotal of cart, which is effectively the total of all the items multiplied by their quantites. Does NOT include order_totals
    def sub_total
      @storage_engine.sub_total
    end

    # Adds an item (or a quantity of that item) to the cart. If the item already exists, the internal quantity will be incremented by the quantity paramater
    def add_to_cart(item, quantity = 1)
      @storage_engine.add_to_cart(item, quantity)
    end

    # Removes an item (or a quantity of that item) from the cart. If final total is 0, the item will be removed from the cart
    def remove_from_cart(item, quantity = 1)
      @storage_engine.remove_from_cart(item, quantity)
    end
    
    # Returns the total of the cart. THis includes all the order_total calculations
    def total
      sub_total + order_total_calculators.total
    end
  end
end
