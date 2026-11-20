module DocumentTypes
  class DirectDepositInformation < DocumentType
    class << self
      def relevant_to?(_intake)
        false #False to avoid polluting document_types_possibly_needed while rules are implemented
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
