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
  # The CartEngine object uses a state machine to track the state of the cart. The default states are: shopping, checkout, verifying_payment, completed, failed. It exposed the following transitions:
  # continue_shopping, checkout, check_payment, payment_successful, payment_failed
  #
  #   @cart.checkout! # transitions from shopping or verifying_payment to checkout
  #   @cart.check_payment! # transistions from checkout to verifying_payment
  #   @cart.payment_successful! # transitions from verifying_payment to completed
  #   @cart.payment_failed! # transitions from verifying_payment to failed
  #   @cart.continue_shopping! # transitions from checkout or verifying_payment to shopping
  #
  class Cart
    attr_accessor :storage_engine, :order_total_calculators, :customer
    include Enumerable
    
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
    # Callbacks:
    #
    # Calls the storage engines before_add_to_cart(item, quantity) and after_add_to_cart(item, quantity) methods (if they exist). If before_add_to_cart returns false, the add will be halted.
    # Calls the items before_add_to_item(quantity) and after_add_to_cart(quantity) methods (if they exist). If before_add_to_cart returns false, the add will be halted.
    #
    def add_to_cart(item, quantity = 1)
      return false unless item.before_add_to_cart(quantity) if item.respond_to?(:before_add_to_cart)
      return false unless @storage_engine.before_add_to_cart(item, quantity) if @storage_engine.respond_to?(:before_add_to_cart)
      @storage_engine.add_to_cart(item, quantity)
      @storage_engine.after_add_to_cart(item, quantity) if @storage_engine.respond_to?(:after_add_to_cart)
      item.after_add_to_cart(quantity) if item.respond_to?(:after_add_to_cart)
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
    # Callbacks:
    #
    # Calls the storage engines before_remove_from_cart(item, quantity) and after_remove_from_cart(item, quantity) methods (if they exist). If before_remove_from_cart returns false, the remove will be halted.
    # Calls the items before_remove_from_item(quantity) and after_remove_from_cart(quantity) methods (if they exist). If before_remove_from_cart returns false, the remove will be halted.
    #
    def remove_from_cart(item, quantity = 1)
      return false unless item.before_remove_from_cart(quantity) if item.respond_to?(:before_remove_from_cart)
      return false unless @storage_engine.before_remove_from_cart(item, quantity) if @storage_engine.respond_to?(:before_remove_from_cart)
      @storage_engine.remove_from_cart(item, quantity)
      @storage_engine.after_remove_from_cart(item, quantity) if @storage_engine.respond_to?(:after_remove_from_cart)
      item.after_remove_from_cart(quantity) if item.respond_to?(:after_remove_from_cart)
    end
    
    # Returns the total of the cart. This includes all the order_total calculations
    #
    def total
      sub_total + order_total_calculators.total
    end

    # Returns the current state of the cart storage engine
    #
    def state
      storage_engine.state
    end

    # :nodoc
    def method_missing(symbol, *args)
      # This allows developers to add extra aasm event transaction, and still allow them to called from the cart
      if @storage_engine.class.aasm_events.keys.include?(symbol.to_s[0..-2].to_sym)
        @storage_engine.send(symbol)
      else
        super
      end
    end
  end
end
