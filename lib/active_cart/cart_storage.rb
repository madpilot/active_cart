# Mixin this module into the class you want to use as your storage class. Remember to override the invoice_id method
#
module ActiveCart
  # The CartStorage object uses a state machine to track the state of the cart. The default states are: shopping, checkout, verifying_payment, completed, failed. It exposed the following transitions:
  # continue_shopping, checkout, check_payment, payment_successful, payment_failed
  #
  #   @cart.checkout! # transitions from shopping or verifying_payment to checkout
  #   @cart.check_payment! # transistions from checkout to verifying_payment
  #   @cart.payment_successful! # transitions from verifying_payment to completed
  #   @cart.payment_failed! # transitions from verifying_payment to failed
  #   @cart.continue_shopping # transitions from checkout or verifying_payment to shopping
  #   
  #   It will fire before_ and after callbacks with the same name as the transitions
  #
  module CartStorage
    def self.included(base) #:nodoc:
      base.send :include, AASM

      base.aasm_initial_state :shopping
      base.aasm_state :shopping, :enter => :enter_shopping, :exit => :exit_shopping
      base.aasm_state :checkout, :enter => :enter_checkout, :exit => :exit_checkout
      base.aasm_state :verifying_payment, :enter => :enter_verifying_payment, :exit => :exit_verifying_payment
      base.aasm_state :completed, :enter => :enter_completed, :exit => :exit_completed
      base.aasm_state :failed, :enter => :enter_failed, :exit => :exit_failed

      base.aasm_event :continue_shopping do
        transitions :from => [ :checkout, :verifying_payment ], :to => :shopping, :guard => :guard_continue_shopping
      end

      base.aasm_event :checkout do
        transitions :from => [ :shopping, :verifying_payment ], :to => :checkout, :guard => :guard_checkout
      end

      base.aasm_event :check_payment do
        transitions :from => :checkout, :to => :verifying_payment, :guard => :guard_check_payment
      end

      base.aasm_event :payment_successful do
        transitions :from => :verifying_payment, :to => :completed, :guard => :guard_payment_successful
      end

      base.aasm_event :payment_failed do
        transitions :from => :verifying_payment, :to => :failed, :guard => :guard_payment_failed
      end
    end

    # Guard continue shopping. If this method returns false, the transition will be halted
    #
    def guard_continue_shopping
      true
    end

    # Guard checkout. If this method returns false, the transition will be halted
    #
    def guard_checkout
      true
    end
    
    # Guard check payment. If this method returns false, the transition will be halted
    #
    def guard_check_payment
      true
    end
    
    # Guard payment successful. If this method returns false, the transition will be halted
    #
    def guard_payment_successful
      true
    end
    
    # Guard payment failed. If this method returns false, the transition will be halted
    #
    def guard_payment_failed
      true
    end

    # Called when entering the shopping state
    #
    def enter_shopping; end
    
    # Called when exiting the shopping state
    #
    def exit_shopping; end

    # Called when entering the checkout state
    #
    def enter_checkout; end

    # Called when existing the checkout state
    #
    def exit_checkout; end
    
    # Called when entering the verifying_payment state
    #
    def enter_verifying_payment; end
    
    # Called when exiting the verifying_payment state
    #
    def exit_verifying_payment; end
    
    # Called when entering the completed state
    #
    def enter_completed; end
    
    # Called when existing the completed state
    #
    def exit_completed; end
    
    # Called when entering the failed state
    #
    def enter_failed; end
    
    # Called when existing the failed state
    #
    def exit_failed; end

    # Returns the unique invoice_id for this cart instance. This MUST be overriden by the concrete class this module is mixed into, otherwise you
    # will get a NotImplementedError
    #
    def invoice_id
      raise NotImplementedError
    end

    # Returns the sub-total of all the items in the cart. Usually returns a float.
    #
    #   @cart.sub_total # => 100.00
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
    #   @cart.add_to_cart(item, 5)
    #   @cart.quantity # => 5
    #
    #   @cart.add_to_cart(item, 2)
    #   @cart.quantity # => 7
    #   @cart[0].quantity # => 7
    #   @cart[1] # => nil
    #
    #   @cart.add_to_cart(item_2, 4)
    #   @cart.quantity => 100
    #   @cart[0].quantity # => 7
    #   @cart[1].quantity # => 4
    #
    def add_to_cart(item, quantity = 1, options = {})
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
    #   @cart.add_to_cart(item, 5)
    #   @cart[0].quantity # => 5
    #   @cart.remove_from_cart(item, 3)
    #   @cart[0].quantity # => 2
    #   @cart.remove_from_cart(item, 2)
    #   @cart[0] # => nil
    #   
    #   @cart.add_to_cart(item, 3)
    #   @cart[0].quantity # => 3
    #   @cart_remove_from_cart(item, :all)
    #   @cart[[0].quantity # => 0
    def remove_from_cart(item, quantity = 1, option = {})
      if self.include?(item)
        index = self.index(item)
        
        quantity = self.at(index).quantity if quantity == :all

        if (existing = self.at(index)).quantity - quantity > 0
          existing.quantity = existing.quantity - quantity
        else
          self.delete_at(index)
        end
      end
    end

    def state
      return aasm_current_state
    end
  end
end
