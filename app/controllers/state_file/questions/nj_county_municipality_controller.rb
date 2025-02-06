require 'csv'

module StateFile

  module Questions
    class NjCountyMunicipalityController < QuestionsController
      include ReturnToReviewConcern
      before_action :set_option_vars, only: [:edit, :update]

      def set_option_vars
        @municipalities_by_county = Efile::Nj::NjMunicipalities.municipality_select_options_for_all_counties
      end
    end
  end
end
