module StateFile
  class EfileDeviceInfoForm < QuestionsForm
    set_attributes_for :efile_device_info,
                       :device_type,
                       :ip_address,
                       :ipts,
                       :device_id
    def save
      attributes = attributes_for(:efile_device_info).merge(intake: @intake)
      # StateFileEfileDeviceInfo.create!(attributes)
    end
  end
end