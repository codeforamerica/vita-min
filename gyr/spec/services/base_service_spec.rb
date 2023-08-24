require 'rails_helper'

describe BaseService do
  describe '.ensure_transaction' do
    context "with a caller inside of a transaction" do
      it "doesn't raise an error and yields" do
        ActiveRecord::Base.transaction do
          expect { BaseService.ensure_transaction{ |_| } }.not_to raise_error
          expect { |block| BaseService.ensure_transaction(&block) }.to yield_with_no_args
        end
      end
    end

    context "with a caller outside of a transaction" do
      it "raises an error" do
        expect { BaseService.ensure_transaction{ |_| } }.to raise_error(StandardError, "Service requiring transaction was called without a transaction open")
      end
    end
  end
end
