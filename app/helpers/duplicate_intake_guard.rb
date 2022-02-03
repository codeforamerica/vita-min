class DuplicateIntakeGuard < SimpleDelegator
  def has_duplicate?
    intake = Intake.find(id)
    return if intake.primary_ssn == nil

    dupes = DeduplificationService.duplicates(intake, :hashed_primary_ssn)

    if intake.type == "Intake::GyrIntake"
      dupes.any?(&:drop_off?) ? dupes.exists? : dupes.exists?(primary_consented_to_service: "yes")
    else
      dupes.exists?('sms_phone_number_verified_at != nil OR email_address_verified_at != nil OR navigator_has_verified_client_identity != nil')
    end
  end
end
