class DuplicateIntakeGuard < SimpleDelegator
  def get_duplicates
    Intake
      .where(intake_pdf_sent_to_zendesk: true)
      .where(
        (arel_table[:email_address].eq(email_address)
          .and(arel_table[:email_address].not_eq(nil)))
        .or(arel_table[:phone_number].eq(phone_number)
          .and(arel_table[:phone_number].not_eq(nil)))
      )
  end

  def has_duplicate?
    get_duplicates.exists?
  end

  private

  def arel_table
    Intake.arel_table
  end
end
