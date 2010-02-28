require 'machinist/active_record'
require 'sham'
require 'faker'

Cart.blueprint do
  state { 'shopping' }  
end

Item.blueprint do
  name { Faker::Lorem.words(2).join(' ') }
  price { (rand(9999) + 1).to_i / 100 }
end

CartItem.blueprint do
  cart { Cart.make }
  name { Faker::Lorem.words(2).join(' ') }
  quantity { rand(10).to_i }
  price { (rand(9999) + 1).to_i / 100 }
  original { Item.make }
end

OrderTotal.blueprint do
  cart { Cart.make }
  name { Faker::Lorem.words(2).join(' ') }
  total { (rand(9999) + 1).to_i / 100 }
end
