module SubmissionBuilder
  module StateFile
    def from_state_code_and_year(state_code, year)
      unless ::StateFile::StateInformationService::STATES_INFO.key?(state_code)
        raise StandardError state_code
      end
      builder = "SubmissionBuilder::Ty#{year.to_i}::States::#{state_code.to_s.titleize}::IndividualReturn"
      builder.constantize
    end

    def from_state_code(state_code)
      # TODO: I am hard coding 2022 as the current year here because we don't have anything else defined yet
      from_state_code_and_year(state_code, 2022)
    end

    module_function :from_state_code_and_year
    module_function :from_state_code
  end
end