class TestOrderTotal
  attr_accessor :price, :active
  def initialize(price, active = true)
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
