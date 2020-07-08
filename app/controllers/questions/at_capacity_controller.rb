module Questions
  class AtCapacityController < QuestionsController
    layout "application"

    def edit
      current_intake.update(viewed_at_capacity: true)
    end

    def update
      current_intake.update(continued_at_capacity: true)
      redirect_to(next_path)
    end

    class << self
      def show?(intake)
        return false unless intake.vita_partner

        intake_from_partner_url = intake.vita_partner.source_parameters.pluck(:code).include?(intake.source)
        intake.vita_partner.at_capacity? && !intake_from_partner_url
      end
    end
  end
end