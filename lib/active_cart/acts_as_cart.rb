require 'active_record'
require 'aasm'
require 'aasm/persistence/active_record_persistence'

module ActiveCart
  module Acts
    module Cart
      def self.included(mod)
        mod.extend(ClassMethods)
      end

      module ClassMethods
        def acts_as_cart(options = {})
          class_eval do
            extend Forwardable
            extend ActiveCart::Acts::Cart::SingletonMethods
            #include AASM::Persistence::ActiveRecordPersistence
            include ActiveCart::CartStorage

            # TODO: Make these configurable
            def invoice_id
              read_attribute(:invoice_id)
            end
            
            def state
              return read_attribute(:state)
            end
          end

          cattr_accessor :aac_config

          self.aac_config = {
            :state_column => 'state',
            :cart_id_column => 'cart_id'
          }

          self.aac_config.merge!(options)
          
          aasm_column self.aac_config[:state_column]
          has_many :cart_items
          has_many :order_totals

          def_delegators :cart_items, :[], :<<, :[]=, :at, :clear, :collect, :map, :delete, :delete_at, :each, :each_index, :empty?, :eql?, :first, :include?, :index, :inject, :last, :length, :pop, :push, :shift, :size, :unshift
        end
      end
      
      module SingletonMethods
        def find_by_cart_id(id)
          self.find(:first, :conditions => [ "#{self.aac_config[:cart_id_column]} = ?",  id ])
        end
      end
    end

    module Item
      def self.included(mod)
        mod.extend(ClassMethods)
      end

      module ClassMethods
        def acts_as_cart_item(options = {})
          belongs_to :cart
          belongs_to :original, :polymorphic => true
        end
      end
    end

    module OrderTotal
      def self.included(mod)
        mod.extend(ClassMethods)
      end

      module ClassMethods
        def acts_as_order_total(options = {})
          belongs_to :cart
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
