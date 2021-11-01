class BaseService
  def self.ensure_transaction
    # require 2 open transactions in test, otherwise 1. this is due to the default rspec transaction.
    required_open_transactions = Rails.env.test? ? ActiveRecord::Base.connection.open_transactions > 1 : ActiveRecord::Base.connection.open_transactions.positive?
    raise StandardError, "Service requiring transaction was called without a transaction open" unless required_open_transactions

    yield
  end
end
