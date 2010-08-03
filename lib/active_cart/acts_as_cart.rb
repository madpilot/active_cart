require 'active_record'
require 'aasm'
#require 'aasm/persistence/active_record_persistence'

module ActiveCart
  module Acts
    module Cart
      #:nodoc
      def self.included(mod)
        mod.extend(ClassMethods)
      end

      module ClassMethods
        # acts_as_cart - Turns an ActiveRecord model in to a cart. It can take a hash of options
        #
        #   state_column: The database column that stores the persistent state machine state. Default: state
        #   invoice_id_column: The column that stores the invoice id. Default: invoice_id
        #   cart_items: The model that represents the items for this cart. Is associated as a has_many. Default: cart_items
        #   order_totals: The model that represents order totals for this cart. It is associated as a has_many. Default: order_totals
        #
        # Example
        #
        #   class Cart < ActiveModel::Base
        #     acts_as_cart
        #   end
        #
        # The only two columns that are required for a cart model are the state_column and invoice_id_column
        #
        # You can create custom acts_as_state_machine (aasm) states and events after declaring acts_as_cart
        #
        # NOTE: this is a STORAGE ENGINE, so you need to create it (by finding by id) then pass the result in to ActiveCart::Cart.new. It might look something like this
        # (Most likely in ApplicationController):
        #
        #   if session[:cart_id]
        #     engine = Cart.find(session[:cart_id])
        #     @cart = ActiveCart.new(engine) if engine
        #   end
        #
        def acts_as_cart(options = {})
          cattr_accessor :aac_config
          
          self.aac_config = {
            :state_column => :state,
            :invoice_id_column => :invoice_id,
            :cart_items => :cart_items,
            :order_totals => :order_totals
          }

          self.aac_config.merge!(options)

          class_eval do
            #include AASM::Persistence::ActiveRecordPersistence
            include ActiveCart::CartStorage

            #:nodoc
            def invoice_id
              read_attribute(self.aac_config[:invoice_id_column])
            end
            
            #:nodoc
            def state
              read_attribute(self.aac_config[:state_column])
            end

            #:nodoc
            def find_cart_item(item, options = {})
              self.send(:cart_items).find(:first, :conditions => [ 'original_id = ? AND original_type = ?', item.id, item.class.to_s ])
            end

            #:nodoc
            def add_to_cart(item, quantity = 1, options = {})
              cart_item = find_cart_item(item, options)
              if cart_item
                cart_item.quantity += quantity
                cart_item.save!
              else
                cart_item = self.send(:cart_items).create!(self.aac_config[:cart_items].to_s.classify.constantize.new_from_item(item, { :quantity => quantity }.merge(options)).attributes.delete_if {|key, value| value == nil})
              end
              self.reload 
            end

            #:nodoc
            def remove_from_cart(item, quantity = 1, options = {})
              cart_item = find_cart_item(item, options)
              if cart_item
                quantity = cart_item.quantity if quantity == :all

                if cart_item.quantity - quantity > 0
                  cart_item.quantity = cart_item.quantity - quantity
                  cart_item.save!
                else
                  cart_item.destroy
                end
              end
              self.reload 
            end

            #:nodoc
            def update_cart(item, quantity = 1, options = {})
              cart_item = find_cart_item(item, options)
              if cart_item
                diff = quantity - cart_item.quantity
                
                if diff < 0
                  return remove_from_cart(item, -1 * diff, options)
                else
                  return add_to_cart(item, diff, options)
                end
              else
                return add_to_cart(item, quantity, options)
              end
            end
          end
         
          aasm_column self.aac_config[:state_column]

          has_many self.aac_config[:cart_items], :dependent => :destroy
          has_many self.aac_config[:order_totals], :dependent => :destroy

          extend Forwardable
          def_delegators self.aac_config[:cart_items], :[], :<<, :[]=, :at, :clear, :collect, :map, :delete, :delete_at, :each, :each_index, :empty?, :eql?, :first, :include?, :index, :inject, :last, :length, :pop, :push, :shift, :size, :unshift
        end
      end
    end

    module Item
      #:nodoc
      def self.included(mod)
        mod.extend(ClassMethods)
      end

      module ClassMethods
        # acts_as_cart_item - Sets up an ActiveModel as an cart item.
        #
        # Cart Items are slightly different to regular items (that may be created in a backend somewhere). When building shopping carts, one of the problems when building
        # shopping carts is how to store the items associated with a particular invoice. One method is to serialize Items and storing them as a blob. This causes problem if
        # the object signature changes, as you won't be able to deserialize an object at a later date. The other option is to duplicate the item into another model
        # which is the option acts_as_cart takes (ActiveCart itself can do either, by using a storage engine that supports the serialization option). As such, carts based
        # on act_as_cart will need two tables, most likely named items and cart_items. In theory, cart_items only needs the fields required to fulfill the requirements of
        # rendering an invoice (or general display), but it's probably easier to just duplicate the fields. The cart_items will also require a cart_id and a quantity field
        # acts_as_cart uses the 'original' polymorphic attribute to store a reference to the original Item object. The compound attribute gets nullified if the original Item gets
        # deleted.
        #
        # When adding an item to a cart, you should pass in the actual concrete item, not the cart_item - the model will take care of the conversion. 
        #
        # For complex carts with multiple item types, you will probably need to use STI, as it's basically impossible to use a polymorphic relationship (If someone can
        # suggest a better way, I'm all ears). That said, there is no easy way to model complex carts, so I'll leave this as an exercise for the reader.
        #
        # Options:
        #
        #   cart: The cart model. Association as a belongs_to. Default: cart
        #   quantity_column: The column that stores the quantity of this item stored in the cart. Default: quantity
        #   name_column: The column that stores the name of the item. Default: name
        #   price_column: The column that stores the price of the item. Default: price
        #   foreign_key: The column that stores the reference to the cart. Default: [cart]_id (Where cart is the value of the cart option)
        #
        # Example
        #
        #   class Item < ActiveModel::Base
        #     acts_as_item
        #   end
        #
        def acts_as_cart_item(options = {})
          cattr_accessor :aaci_config
          
          self.aaci_config = {
            :cart => :cart,
            :quantity_column => :quantity,
            :name_column => :name,
            :price_column => :price
          }
          self.aaci_config.merge!(options)
          self.aaci_config[:foreign_key] = (self.aaci_config[:cart].to_s + "_id").to_sym unless options[:foreign_key]

          class_eval do
            include ActiveCart::Item
          
            def id
              read_attribute(:id)
            end

            def name
              read_attribute(self.aaci_config[:name_column])
            end

            def quantity
              read_attribute(self.aaci_config[:quantity_column])
            end 

            def quantity=(quantity)
              write_attribute(self.aaci_config[:quantity_column], quantity)
            end

            def price
              read_attribute(self.aaci_config[:price_column])
            end
          end
          
          # Creates a new cart_item item for the passed in concrete item
          #
          # The default copies all the common attributes from the passed in item to new cart_item (Except id and timestamps). Override it if you want to do something special.
          #
          def new_from_item(item, options = {})
            cart_item = item.send(self.to_s.tableize).build(options)
            cart_item.attributes.map {|attribute| attribute if cart_item.original.respond_to?(attribute[0].to_s) && !attribute[0].to_s.include?("_at") }.compact.each {|attribute| cart_item.send("#{attribute[0]}=", cart_item.original.send(attribute[0].to_s))}
            # TODO Add a callback
            cart_item
            # TODO Add a callback
          end

          belongs_to self.aaci_config[:cart], :foreign_key => self.aaci_config[:foreign_key]
          belongs_to :original, :polymorphic => true
        end
      end
    end

    module OrderTotal
      #:nodoc
      def self.included(mod)
        mod.extend(ClassMethods)
      end

      module ClassMethods
        # acts_as_order_total - Turns an ActiveModel into an order_total store.
        #
        # In the same way there is a seperation between items and cart_items, there is a difference between concrete order_total objects and this order_total store.
        # This model acts as a way of archiving the order total results for a given cart, so an invoice can be retrieved later. It doesn't matter if the concrete order_total
        # object is an ActiveModel class or not, as long as it matches the api
        #
        # Options:
        #
        #   cart: The cart model. Association as a belongs_to. Default: cart
        #   name_column: The column that stores the name of the item. Default: name
        #   price_column: The column that stores the price of the item. Default: price
        #   foreign_key: The column that stores the reference to the cart. Default: [cart]_id (Where cart is the value of the cart option)
        #
        # Example
        #
        #   class OrderTotal < ActiveModel::Base
        #     acts_as_order_total
        #   end
        #
        def acts_as_order_total(options = {})
          cattr_accessor :aaot_config
          
          self.aaot_config = {
            :cart => :cart,
            :name_column => :name,
            :price_column => :price
          }
          self.aaot_config.merge!(options)
          self.aaot_config[:foreign_key] = (self.aaot_config[:cart].to_s + "_id").to_sym unless options[:foreign_key]

          class_eval do
            include ActiveCart::Item
          
            def id
              read_attribute(:id)
            end

            def name
              read_attribute(self.aaot_config[:name_column])
            end

            def price
              read_attribute(self.aaot_config[:price_column])
            end
          end

          belongs_to self.aaot_config[:cart], :foreign_key => self.aaot_config[:foreign_key]
        end
      end
    end
  end
end

ActiveRecord::Base.class_eval do
  include ActiveCart::Acts::Cart
  include ActiveCart::Acts::Item
  include ActiveCart::Acts::OrderTotal
end
