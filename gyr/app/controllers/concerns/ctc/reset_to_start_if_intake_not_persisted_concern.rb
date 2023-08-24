module Ctc
  module ResetToStartIfIntakeNotPersistedConcern
    extend ActiveSupport::Concern

    included do
      before_action :check_intake_persisted
    end

    private

    def check_intake_persisted
      redirect_to Ctc::Questions::IncomeController.to_path_helper unless current_intake&.persisted?
    end
  end
end
