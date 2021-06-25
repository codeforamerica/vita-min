module Questions
  class CharitableContributionsController < QuestionsController
    include AuthenticatedClientConcern

    layout "yes_no_question"

    # For the 2021 tax year, even those taking the standard deduction can deduct up to $300 in charitable expenses
    # so we show to everyone.
    def self.show?(_intake)
      true
    end

    private

    def method_name
      "paid_charitable_contributions"
    end
  end
end
