module Questions
  class SavingsOptionsController < QuestionsController
    include AuthenticatedClientConcern

    layout 'yes_no_question'

    def self.show?(intake)
      intake.refund_direct_deposit_yes?
    end

    def illustration_path
      'hand-holding-check.svg'
    end

    def method_name
      'savings_split_refund'
    end
  end
end
