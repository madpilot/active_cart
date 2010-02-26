class TestItem
  include ActiveCart::Item

  attr_accessor :id

  def ==(item)
    self.id == item.id
  end

  def initialize(id = 1)
    self.id = id
  end

  def id
    @id
  end

  def name
    "Test item"
  end

  def price
    @price || 2
  end

  def price=(price)
    @price = price
  end

  def inspect
    "#{name}: #{self.id}: #{self.quantity}x$#{self.price}"
  end
end
