module StateFile
  class NycResidencyForm < QuestionsForm
    set_attributes_for :intake,
                       :nyc_residency,
                       :nyc_maintained_home
    set_attributes_for :state_file_efile_device_info, :device_id

    before_validation :clear_maintained_home_for_residents

    validates :nyc_residency, presence: true
    validates :nyc_maintained_home, presence: true, if: -> { nyc_residency == "none" }

    def save
      efile_info = StateFileEfileDeviceInfo.find_by(event_type: "initial_creation", intake: @intake)
      efile_info&.update!(attributes_for(:state_file_efile_device_info))

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