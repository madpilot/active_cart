$:.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
$:.unshift(File.join(File.dirname(__FILE__)))

require 'rubygems'
require 'redgreen'
require 'test/unit'
require 'shoulda'
require 'mocha'

require 'active_cart'
require 'mocks/test_cart_storage'
require 'mocks/test_item'
require 'mocks/test_order_total'

class Test::Unit::TestCase
end
