class TestCartStorage < Array
  include ActiveCart::CartStorage

  def invoice_id
    'Invoice #1'
  end
end
