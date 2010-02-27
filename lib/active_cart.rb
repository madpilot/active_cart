$:.unshift(File.join(File.dirname(__FILE__), 'active_cart'))

require 'rubygems'
require 'singleton'
require 'forwardable'
require 'aasm'
require 'item'
require 'cart_storage'
require 'order_total'
require 'order_total_collection'
require 'cart'
require 'acts_as_cart' if (Kernel.const_defined?('RAILS_ENV') || Kernel.const_defined?('Rails'))

require 'storage_engines/memory'
require 'items/memory_item'

module ActiveCart
  VERSION = File.exist?('VERSION') ? File.read('VERSION') : ""
end
