module StateFile
  module Questions
    class NcTaxesOwedController < TaxesOwedController
      def self.form_key
        "state_file/taxes_owed_form"
      end
    end
  end
end
