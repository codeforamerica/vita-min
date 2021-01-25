class DuplicateIntakeGuard < SimpleDelegator
  def has_duplicate?
    permitted_eip_only_values = eip_only ? true : [nil, false]
    Intake
      .where(primary_consented_to_service: "yes")
      .where(eip_only: permitted_eip_only_values)
      .where(
         (arel_table[:email_address].eq(email_address)
           .and(arel_table[:email_address].not_eq(nil)))
         .or(arel_table[:phone_number].eq(phone_number)
           .and(arel_table[:phone_number].not_eq(nil)))
      ).exists?
  end

  private

  def arel_table
    Intake.arel_table
  end
end
