namespace :not_ready do
  desc "sends not ready reminder emails"
  task "remind" => :environment do
    next if Time.current > Rails.configuration.end_of_intake

    remindable_returns = TaxReturn.joins(:intake, :client).where(current_state: "intake_in_progress", intakes: { type: "Intake::GyrIntake" }).where('tax_returns.updated_at < ?', 3.days.ago)
    remindable_returns.find_each do |tax_return|
      NotReadyReminder.process(tax_return)
    end
  end
end
