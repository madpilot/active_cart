module ActiveCart
  module OrderTotal
    def active?
      @active || false
    end

    def active=(active)
      @active = active
    end

    def price(cart)
      raise NotImplementedError
    end

    def name
      raise NotImplementedError
    end

    def description
      raise NotImplementedError
    end
  end
end
