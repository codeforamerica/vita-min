module StateFile
  class AzStateCreditsForm < QuestionsForm
    set_attributes_for :intake, :tribal_member, :tribal_wages, :armed_forces_member, :armed_forces_wages

    validates :tribal_wages, presence: true, allow_blank: false, gyr_numericality: { only_integer: true, greater_than_or_equal_to: 1 }, if: -> { tribal_member == "yes" }
    validates :armed_forces_wages, presence: true, allow_blank: false, gyr_numericality: { only_integer: true, greater_than_or_equal_to: 1 }, if: -> { armed_forces_member == "yes" }

    def save
      attributes_to_save = attributes_for(:intake)
      attributes_to_save[:tribal_wages] = nil if tribal_member == "no"
      attributes_to_save[:armed_forces_wages] = nil if armed_forces_member == "no"
      @intake.update(attributes_to_save)
    end
  end
end