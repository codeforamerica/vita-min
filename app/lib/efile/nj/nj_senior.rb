module Efile
  module Nj
    class NjSenior
      def self.is_over_65(birth_date)
        return false unless birth_date.present?
        over_65_birth_year = MultiTenantService.new(:statefile).current_tax_year - 65
        birth_date <= Date.new(over_65_birth_year, 12, 31)
      end
    end
  end
end
