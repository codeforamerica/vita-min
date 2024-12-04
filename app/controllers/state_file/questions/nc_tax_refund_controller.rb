module StateFile
  module Questions
    class NcTaxRefundController < TaxRefundController
      def self.form_key
        "state_file/tax_refund_form"
      end
    end
  end
end
