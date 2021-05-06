module Questions
  class EverOwnedHomeController < AuthenticatedIntakeController
    layout "yes_no_question"

    private

    def method_name
      "ever_owned_home"
    end
  end
end
