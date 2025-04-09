module StateFile
  module Questions
    class NcTaxesOwedController < TaxesOwedController

      def edit
        @form = initialized_edit_form
        @allow_date_select = StateInformationService.before_payment_deadline?(app_time, current_intake.state_code)
      end
    end
  end
end
