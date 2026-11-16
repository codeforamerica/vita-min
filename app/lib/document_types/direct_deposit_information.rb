module DocumentTypes
  class DirectDepositInformation < DocumentType
    class << self
      def relevant_to?(_intake)
        true #Set to always true until rules are implemented. This ensures that the type always shows in the meantime
      end

      def description
        "Accepts a bank statement or a personal check showing the account and routing numbers."
      end

      def key
        "Direct Deposit Information"
      end
    end
  end
end
