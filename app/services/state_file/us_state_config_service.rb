module StateFile
  class UsStateConfigService
    class << self

      def active_states_by_year
        {
          2023 => [:az, :ny]
        }
      end

      def state_display_name(state_code)
        {
          az: "Arizona",
          ny: "New York"
        }[state_code]
      end

    end
  end
end