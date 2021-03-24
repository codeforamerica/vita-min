module Questions
  class SavingsOptionsController < AuthenticatedIntakeController
    private

    def illustration_path
      "refund-payment.svg"
    end
  end
end
