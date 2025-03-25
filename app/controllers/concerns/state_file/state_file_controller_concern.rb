module StateFile
  module StateFileControllerConcern
    extend ActiveSupport::Concern
    include StateFileCurrentIntakeConcern

    included do
      helper_method :current_tax_year, :current_intake
    end
  end
end