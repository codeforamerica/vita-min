module StateFile
  class WaitingToLoadDataForm < QuestionsForm
    set_attributes_for :state_file_efile_device_info, :device_id

    def save
      # binding.pry
      efile_info = StateFileEfileDeviceInfo.find_by(event_type: "initial_creation", intake: @intake)
      efile_info&.update!(attributes_for(:state_file_efile_device_info))
    end
  end
end