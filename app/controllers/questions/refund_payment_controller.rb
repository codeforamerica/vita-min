module Questions
  class RefundPaymentController < AuthenticatedIntakeController

    private

    def illustration_path
      "hand-holding-check.svg"
    end
  end
end
