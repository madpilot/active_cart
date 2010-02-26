# Mixin this module into any classes that act as an order_total.
#
# You need to overwrite the price, name and description methods
#
module ActiveCart
  module OrderTotal
    
    # Returns a boolean depending if the order total is active in this particular cart
    #
    # @order_total.active? # => true
    #
    def active?
      @active || false
    end

    # Make a particular order_total active
    #
    #  @order_total.active = true
    #  @order_total.active? # => true
    #
    #  @order_total.active = false
    #  @order_total.active? # => falese
    #
    def active=(active)
      @active = active
    end

    # Returns the adjustment caused by this order_total object. Takes a cart object as a parameter, allowing the object to interrogate the items in the cart. 
    #
    # This must be overriden in the mixee class, otherwise it will throw a NotImplementedError
    #
    # @order.price(@cart) => 2
    #
    def price(cart)
      raise NotImplementedError
    end

    # Returns the friendly name of the order total. Can be used for display (Such as on an invoices etc)
    #
    # This must be overriden in the mixee class, otherwise it will throw a NotImplementedError
    #
    # @order.name # => 'My awesome order total class'
    def name
      raise NotImplementedError
    end

    # Returns a short description of the order total. Can be used for display (Such as on an invoices etc)
    #
    # This must be overriden in the mixee class, otherwise it will throw a NotImplementedError
    #
    # @order.description # => "This example order class doesn't do much"
    #
    def description
      raise NotImplementedError
    end
  end
end
