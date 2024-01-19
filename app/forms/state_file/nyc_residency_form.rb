module StateFile
  class NycResidencyForm < QuestionsForm
    set_attributes_for :intake,
                       :nyc_residency,
                       :nyc_maintained_home

    before_validation :clear_maintained_home_for_residents

    validates :nyc_residency, presence: true
    validates :nyc_maintained_home, presence: true, if: -> { nyc_residency == "none" }

    def save
      intake.update(attributes_for(:intake))
    end

    private

    def clear_maintained_home_for_residents
      unless nyc_residency == "none"
        self.nyc_maintained_home = "unfilled"
      end
    end
  end
end