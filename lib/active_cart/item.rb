# Mixin this module into the class you want to act as an item 
#
module ActiveCart
  # 
  module Item
    # A unique id for the item. The Mixee needs to implement this or a NotImplementedError will be thrown
    #
    def id
      raise NotImplementedError
    end

    # A display name for the item. The Mixee needs to implement this or a NotImplementedError will be thrown
    #
    def name
      raise NotImplementedError
    end

    # Returns the quantity of this item in the context of a cart
    #
    def quantity
      @quantity || 0
    end

    # Set the quantity of this item in the context of a cart
    #
    def quantity=(quantity)
      @quantity = quantity
    end

    # Returns the price of this item
    #
    def price
      raise NotImplementedError
    end
  end
end
