class TestItem
  attr_accessor :id, :price, :quantity

  def ==(item)
    self.id == item.id
  end

  def initialize(id = 1)
    self.id = id
    self.quantity = 0
  end

  def price
    @price || 2
  end

  def inspect
    "TestItem: #{self.id}: #{self.quantity}x$#{self.price}"
  end
end
