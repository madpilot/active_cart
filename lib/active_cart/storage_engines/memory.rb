module ActiveCart
  module StorageEngines
    # This storage engine is probably only useful as a reference implementation (It would work in a desktop app I guess). Items only exist in memory, so
    # as soon as the thread dies, so does the cart.
    #
    class Memory < Array
      include ActiveCart::CartStorage
      
      def invoice_id
        @@last_id = @@last_id ? @@last_id + 1 : 1
      end
    end
  end
end
