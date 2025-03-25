module StateFile
  module StateFileCurrentIntakeConcern
    extend ActiveSupport::Concern

    def current_intake
      StateFile::StateInformationService
        &.active_state_codes
        &.lazy
        &.map { |c| send("current_state_file_#{c}_intake".to_sym) }
        &.find(&:itself)
    end

    module_function :current_intake

    def current_tax_year
      MultiTenantService.new(:statefile).current_tax_year
    end
  end
end