class TestOrderTotal
  attr_accessor :price, :active, :name
  def initialize(name, price, active = true)
    @name = name
    @price = price
    @active = active
  end

  def price(cart)
    @price
  end

  def active?
    @active
  end
end
