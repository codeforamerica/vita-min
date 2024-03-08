class UpdateEfileErrorsJob < ApplicationJob
  def perform
    ctc_errors = EfileError.where('created_at < ?', Date.new(2024))
    state_file_errors = EfileError.where('created_at > ?', Date.new(2024))

    ctc_errors.update_all(service_type: :ctc)

    state_file_errors.update_all(service_type: :state_file)
    # state_file_errors.update_all(expose: false)
    DefaultErrorMessages.generate!(service_type: :state_file)

  end

  def priority
    PRIORITY_LOW
  end
end
