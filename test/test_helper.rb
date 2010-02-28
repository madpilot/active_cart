$:.unshift(File.join(File.dirname(__FILE__)))
$:.unshift(File.join(File.dirname(__FILE__), 'fixtures'))
$:.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))

require 'rubygems'
require 'redgreen'
require 'test/unit'
require 'shoulda'
require 'mocha'

require 'active_cart'
require 'mocks/test_cart_storage'
require 'mocks/test_item'
require 'mocks/test_order_total'

require 'active_record'
require 'active_record/fixtures'

# Mock out the required environment variables.
RAILS_ENV = 'test'
RAILS_ROOT = Dir.pwd

ActiveRecord::Base.logger = Logger.new(File.dirname(__FILE__) + '/log/test.log')
ActiveRecord::Base.configurations = YAML::load <<-YAML
  sqlite3:
    :adapter: sqlite3
    :database: ':memory:'
YAML
ActiveRecord::Base.establish_connection('sqlite3')

require 'active_cart/acts_as_cart'

# Load Schema
load(File.dirname(__FILE__) + '/schema.rb')

require 'fixtures/cart'
require 'fixtures/item'
require 'fixtures/cart_item'
require 'fixtures/order_total'
require 'blueprints'

class ActiveSupport::TestCase
  include ActiveRecord::TestFixtures
  self.fixture_path = File.dirname(__FILE__) + '/fixtures/'
  self.use_transactional_fixtures = true
  self.use_instantiated_fixtures  = false
end
