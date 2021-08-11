module Ctc
  class HomeForm < QuestionsForm
    set_attributes_for :misc, :lived_in_fifty_states, :lived_at_military_facility, :lived_in_us_territory, :lived_at_foreign_address

    def save; end

    def lived_in_territory_or_at_foreign_address?
      [lived_in_us_territory, lived_at_foreign_address].any?("yes")
    end
  end
end
