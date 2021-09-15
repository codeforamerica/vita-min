module Ctc
  module Questions
    class BankAccountController < QuestionsController
      include AuthenticatedCtcClientConcern

      layout "intake"

      def self.show?(intake)
        intake.refund_payment_method_direct_deposit?
      end

      def edit
        @form = form_class.from_bank_account(current_model)
      end

      private

      def illustration_path
        "bank-details.svg"
      end

      def initialized_update_form
        form_class.new(current_model, form_params)
      end

      def bank_account_field_type(key)
        unless current_model.persisted?
          return nil
        end

        @form.errors.has_key?(key) ? nil : :password
      end
      helper_method :bank_account_field_type

      def current_model
        return BankAccount.new if params[:clear]

        @_current_model ||= (current_intake.bank_account || current_intake.build_bank_account)
      end
      helper_method :current_model
    end
  end
end
