# Mixin this module into the class you want to user as your storage class. Remember to override the invoice_id method
#
module ActiveCart
  module CartStorage
    # Returns the unique invoice_id for this cart instance. This MUST be overriden by the concrete class this module is mixed into, otherwise you
    # will get a NotImplementedError
    #
    def invoice_id
      raise NotImplementedError
    end

    # Returns the sub-total of all the items in the cart. Usually returns a float.
    #
    # @cart.sub_total # => 100.00
    #
    def sub_total
      inject(0) { |t, item| t + (item.quantity * item.price)  }
    end

    # Returns the number of items in the cart. It takes into account the individual quantities of each item, eg if there are 3 items in the cart, each with a quantity of 2, this will return 6
    #
    def quantity
      inject(0) { |t, item| t + item.quantity }
    end

    # Adds an item to the cart. If the item already exists in the cart (identified by the id of the item), then the quantity will be increased but the supplied quantity (default: 1)
    #
    # @cart.add_to_cart(item, 5)
    # @cart.quantity # => 5
    #
    # @cart.add_to_cart(item, 2)
    # @cart.quantity # => 7
    # @cart[0].quantity # => 7
    # @cart[1] # => nil
    #
    # @cart.add_to_cart(item_2, 4)
    # @cart.quantity => 100
    # @cart[0].quantity # => 7
    # @cart[1].quantity # => 4
    #
    def add_to_cart(item, quantity = 1)
      if self.include?(item)
        index = self.index(item)
        self.at(index).quantity += quantity
      else
        item.quantity += quantity
        self << item
      end
    end

    # Removes an item from the cart (identified by the id of the item). If the supplied quantity is greater than equal to the number in the cart, the item will be removed, otherwise the quantity will simply be decremented by the supplied amount
    #
    # @cart.add_to_cart(item, 5)
    # @cart[0].quantity # => 5
    # @cart.remove_from_cart(item, 3)
    # @cart[0].quantity # => 2
    # @cart.remove_from_cart(item, 2)
    # @cart[0] # => nil
    #
    def remove_from_cart(item, quantity = 1)
      if self.include?(item)
        index = self.index(item)
        if (existing = self.at(index)).quantity - quantity > 0
          existing.quantity = existing.quantity - quantity
        else
          self.delete_at(index)
        end
      end
    end
  end
end
