class BaseService
  def self.ensure_transaction
    raise StandardError, "Service requiring transaction was called without a transaction open" unless ActiveRecord::Base.connection.open_transactions.positive?

    yield
  end
end
