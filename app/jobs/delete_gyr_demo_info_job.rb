class DeleteGyrDemoInfoJob < ApplicationJob
  def perform(exempted_client_ids)
    return if Rails.env.production?

    # Delete all non-exempted GYR clients
    Client.includes(:intake).where(intake: { type: "Intake::GyrIntake" })
          .where.not(id: exempted_client_ids).map(&:destroy)

    # Delete all non-admin users
    User.where.not(role_type: AdminRole::TYPE).map do |user|
      user.assigned_tax_returns.update(assigned_user: nil)
      user.destroy
    end

    # Delete sites GYR sites with no clients
    Site.where(national_overflow_location: false, processes_ctc: false)
        .where.not(name: "GetCTC.org (Site)")
        .where.missing(:clients).map(&:destroy)

    # Don't delete organizations that have no clients but have child sites with clients
    Organization.where(national_overflow_location: false, processes_ctc: false)
      .where.not(name: "GetCTC.org")
      .where.not(name: "GYR National Organization")
      .where.missing(:clients)
      .where.not(id: Site.all.pluck(:parent_organization_id)).map(&:destroy)
  end
end