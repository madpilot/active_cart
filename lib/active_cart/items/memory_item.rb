module ActiveCart
  module Items
    class MemoryItem
      attr_accessor :id, :name, :price
      include ActiveCart::Item

      def ==(item)
        self.id == item.id
      end
      
      def initialize(id, name, price)
        @id = id
        @name = name
        @price = price
      end
    end
  end
end
