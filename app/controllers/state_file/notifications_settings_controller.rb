module StateFile
  class NotificationsSettingsController < ApplicationController
    layout "state_file"

    def unsubscribe_email
      matching_intakes = matching_intakes(params[:email_address])

      if matching_intakes.present?
        matching_intakes.each do |intake|
          intake.update(unsubscribed_from_email: true)
        end
      else
        flash[:alert] = "No record found"
      end
    end

    def subscribe_email
      matching_intakes = matching_intakes(params[:email_address])

      if matching_intakes.present?
        matching_intakes.each do |intake|
          intake.update(unsubscribed_from_email: false)
        end

        flash[:notice] = I18n.t("state_file.notifications_settings.subscribe_email.flash")
        render :unsubscribe_email
      else
        flash[:alert] = "No record found"
      end
    end

    private

    def matching_intakes(email_address)
      return if email_address.blank?

      StateFileAzIntake.where(email_address: email_address) + StateFileNyIntake.where(email_address: email_address)
    end
  end
end
