module StateFile
  module Questions
    class MdTaxesOwedController < TaxesOwedController
      def self.form_key
        "state_file/taxes_owed_form"
      end
    end
  end
end
