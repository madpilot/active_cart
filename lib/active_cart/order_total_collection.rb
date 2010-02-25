module ActiveCart
  class OrderTotalCollection < Array
    # Create a new collection
    def initialize(cart, *seed)
      @cart = cart
      seed.each do |s|
        self.push(s)
      end
    end

    # Created a new collection that is the concatenations of the old collection and the supplied collection. The supplied collections can be a normal array.
    def +(tc)
      tmp = OrderTotalCollection.new(@cart)
      self.each { |s| tmp << s }
      tc.each { |s| tmp << s }
      tmp
    end

    # Inserts the items before the item that is currently at the supplied index
    def insert_before(index, *items)
      items.reverse.each do |item|
        self.insert(index, item)
      end
    end

    #Inserts the items after the item that is currently at the supplied index
    def insert_after(index, *items)
      items.each_with_index do |item, i|
        self.insert(index + i + 1, item)
      end
    end

    # Allows you to reorder the order totals. Moves the item at index <em>from</em> to index <em>to</em>
    def move(from, to)
      index = self.delete_at(from)
      self.insert(to, index)
    end

    # Calculates the total variation caused by the order total objects
    def total
      self.inject(0) { |t, calculator| t + (calculator.active? ? calculator.price(@cart) : 0) }
    end
  end
end
