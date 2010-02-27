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
      base.aasm_state :shopping
      base.aasm_state :checkout
      base.aasm_state :verifying_payment
      base.aasm_state :completed
      base.aasm_state :failed

      base.aasm_event :continue_shopping do
        transitions :from => [ :checkout, :verifying_payment ], :to => :shopping, :enter => :before_continue_shopping, :exit => :after_continue_shopping
      end

      base.aasm_event :checkout do
        transitions :from => [ :shopping, :verifying_payment ], :to => :checkout, :enter => :before_checkout, :exit => :after_checkout
      end

      base.aasm_event :check_payment do
        transitions :from => :checkout, :to => :verifying_payment, :enter => :before_check_payment, :exit => :after_check_payment
      end

      base.aasm_event :payment_successful do
        transitions :from => :verifying_payment, :to => :completed, :enter => :before_payment_successful, :exit => :after_payment_successful
      end

      base.aasm_event :payment_failed do
        transitions :from => :verifying_payment, :to => :failed, :enter => :before_payment_failed, :exit => :after_payment_failed
      end
    end

    # Called before transitioning into continuing_shopping
    #
    def before_continuing_shopping; end
    
    # Called after transitioning into continuing_shopping
    #
    def after_continuing_shopping; end

    # Called before transitioning into checkout
    #
    def before_checkout; end

    # Called after transitioning into checkout
    #
    def after_checkout; end
    
    # Called before transitioning into check_payment
    #
    def before_check_payment; end
    
    # Called after transitioning into check_payment
    #
    def after_check_payment; end
    
    # Called before transitioning into payment_successful
    #
    def before_payment_successful; end
    
    # Called after transitioning into payment_successful
    #
    def after_payment_successful; end
    
    # Called before transitioning into failed
    #
    def before_payment_failed; end
    
    # Called after transitioning into failed
    #
    def after_payment_failed; end

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
    def add_to_cart(item, quantity = 1)
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

    def state
      return aasm_current_state
    end
  end
end
