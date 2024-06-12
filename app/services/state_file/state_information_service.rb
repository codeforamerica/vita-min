module StateFile
  class StateInformationService
    class << self
      def active_states # TODO thinking this could also be called `active_state_codes` or just `state_codes`?
        STATE_INFO.keys.map(&:to_s)
      end

      def state_name(state_code)
        unless active_states.include?(state_code)
          raise StandardError, state_code
        end

        States.name_for_key(state_code.upcase)
      end

      def state_code_to_name_map
        active_states.reduce({}) do |acc, state_code|
          state_name = state_name(state_code)
          acc[state_code] = state_name if state_name
          acc
        end
      end

      def state_code_from_intake_class(klass)
        state_code, _ = STATE_INFO.find do |_,v|
          v[:intake_class] == klass
        end
        state_code.to_s
      end
    end

    private

    STATE_INFO = {
      az: {
        intake_class: StateFileAzIntake,
      },
      ny: {
        intake_class: StateFileNyIntake,
      }
    }
  end
end
