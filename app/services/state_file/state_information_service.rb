module StateFile
  class StateInformationService
    class << self
      def active_state_codes
        STATE_INFO.keys.map(&:to_s)
      end

      def state_name(state_code)
        unless active_state_codes.include?(state_code)
          raise StandardError, state_code
        end

        STATE_INFO[state_code.to_sym][:name]
      end

      def state_code_to_name_map
        active_state_codes.to_h { |state_code, _| [state_code, state_name(state_code)] }
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
        name: "Arizona",
      },
      ny: {
        intake_class: StateFileNyIntake,
        name: "New York",
      }
    }
  end
end
