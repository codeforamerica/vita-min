module DocumentTypes
  class DirectDepositInformation < DocumentType
    class << self
      def description
        "Accepts a bank statement or a personal check showing the account and routing numbers."
      end

      def key
        "Direct Deposit Information"
      end
    end
  end
end
