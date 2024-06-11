module StateFile
  class StateInformationService
    ACTIVE_STATES = ["az", "ny"].freeze

    class << self
      def state_name(state_code)
        States.name_for_key(state_code.upcase)
      end

      def state_code_to_name_map
        ACTIVE_STATES.reduce({}) do |acc, state_code|
          state_name = state_name(state_code)
          acc[state_code] = state_name if state_name
          acc
        end
      end
    end
  end
end
