class StillNeedsHelpService
  def self.must_show_still_needs_help_flow?(client)
    client.triggered_still_needs_help_at.present? && client.tax_returns.where(status: :file_not_filing).exists?
  end

  def self.may_show_still_needs_help_flow?(client)
    client.triggered_still_needs_help_at.present?
  end

  def self.trigger_still_needs_help_flow(client)
    client.triggered_still_needs_help_at = Time.now
    client.tax_returns.where(status: %w[intake_ready intake_in_progress]).update(status: :file_not_filing)
    client.save
  end
end
