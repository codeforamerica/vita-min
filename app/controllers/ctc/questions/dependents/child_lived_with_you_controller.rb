module Ctc
  module Questions
    module Dependents
      class ChildLivedWithYouController < BaseDependentController
        include AuthenticatedCtcClientConcern
        layout "yes_no_question"

        def self.show?(dependent)
          return false unless dependent.present? && dependent.relationship.present?

          return true unless dependent.born_in_final_6_months_of_tax_year?(TaxReturn.current_tax_year)
        end

        def method_name
          'lived_with_more_than_six_months'
        end

        private

        def illustration_path
          "dependents_home.svg"
        end
      end
    end
  end
end
