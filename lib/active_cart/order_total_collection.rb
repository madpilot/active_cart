module ActiveCart
  class OrderTotalCollection < Array
    # Returns a new OrderTotalCollection
    #
    # You must pass in an cart object. 
    #
    # collection = OrderTotalCollection.new(@cart)
    #
    # You can also pass in an array of order_total objects
    #
    # cart = ActiveCart::Cart.instance
    # collection = OrderTotalCollection.new(cart, order_total_1, order_total_2)  # => [ order_total_1, order_total_2 ]
    #
    def initialize(cart, *seed)
      @cart = cart
      seed.each do |s|
        self.push(s)
      end
    end

    # Concatenation.Returns a new OrderTotalCollection built by concatenating the two OrderTotalCollections together to produce a third OrderTotalCollection. (The supplied collection can be a regular array)
    #
    # [ order_total_1, order_total_2, order_total_3 ] + [ order_total_4, order_total_5 ] #=> [ order_total_1, order_total_2, order_total_3, order_total_4, order_total_5 ]
    #
    def +(order_total_collection)
      tmp = OrderTotalCollection.new(@cart)
      self.each { |s| tmp << s }
      order_total_collection.each { |s| tmp << s }
      tmp
    end

    # Inserts the items before the item that is currently at the supplied index
    #
    # items = [ order_total_1, order_total_2 ]
    # items.insert_before(1, order_total_2) #=> [ order_total_1, order_total_3, order_total_2 ]
    #
    def insert_before(index, *items)
      items.reverse.each do |item|
        self.insert(index, item)
      end
      self
    end

    # Inserts the items after the item that is currently at the supplied index
    #
    # items = [ order_total_1, order_total_2 ]
    # items.insert_after(0, order_total_2) #=> [ order_total_1, order_total_3, order_total_2 ]
    #
    def insert_after(index, *items)
      items.each_with_index do |item, i|
        self.insert(index + i + 1, item)
      end
      self
    end

    # Allows you to reorder the order totals. Moves the item at index <em>from</em> to index <em>to</em>
    #
    # items = [ order_total_1, order_total_2 ]
    # items.move(0, 1) #=> [ order_total_2, order_total_1 ]
    #
    def move(from, to)
      index = self.delete_at(from)
      self.insert(to, index)
    end

    # Calculates the total price applied by all the order_total objects.
    #
    # order_total_collection = OrderTotalCollection.new(nil, order_total_1, order_total_2)
    # order_total_collection.total # => 10
    #
    def total
      self.inject(0) { |t, calculator| t + (calculator.active? ? calculator.price(@cart) : 0) }
    end
  end
end
