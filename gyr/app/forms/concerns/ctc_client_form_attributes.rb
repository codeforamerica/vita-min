module CtcClientFormAttributes
  extend ActiveSupport::Concern

  def reduce_dirty_attributes(intake, attributes)
    # For boolean columns that have a default(FALSE) but no 'not null'.
    # Since these checkboxes sometimes don't appear on the form,
    # the value from `params` might be nil, which we don't want to go
    # into the database.
    # Ensure that we write 'false' on create but retain any existing
    # value on update.
    %i(
      with_general_navigator
      with_incarcerated_navigator
      with_limited_english_navigator
      with_unhoused_navigator
      with_drivers_license_photo_id
      with_itin_taxpayer_id
      with_other_state_photo_id
      with_passport_photo_id
      with_social_security_taxpayer_id
      with_vita_approved_photo_id
      with_vita_approved_taxpayer_id
    ).each do |column|
      if intake&.persisted?
        attributes[column] ||= intake.send(column)
      else
        attributes[column] ||= false
      end
    end

    # sms_notification_opt_in will often come in "unfilled" during intake
    # and we don't want the valet form to flip it to "no" unnecessarily
    %i(
      email_notification_opt_in
      sms_notification_opt_in
    ).each do |column|
      if intake&.persisted? && attributes[column] != "yes"
        attributes[column] = intake.send(column)
      end
    end
  end
end
