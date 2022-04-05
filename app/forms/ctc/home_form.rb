module Ctc
  class HomeForm < QuestionsForm
    set_attributes_for :misc, :home_location

    def save; end

    def lived_in_territory_or_at_foreign_address?
      ["lived_in_us_territory", "lived_at_foreign_address"].include? home_location
    end
  end
end
