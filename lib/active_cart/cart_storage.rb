module ActiveCart
  module CartStorage
    def invoice_id
      raise NotImplementedError
    end

    def sub_total
      inject(0) { |t, item| t + (item.quantity * item.price)  }
    end

    def quantity
      inject(0) { |t, item| t + item.quantity }
    end

    def add_to_cart(item, quantity = 1)
      if self.include?(item)
        index = self.index(item)
        self.at(index).quantity += quantity
      else
        item.quantity += quantity
        self << item
      end
    end

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
