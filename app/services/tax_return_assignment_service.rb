class TaxReturnAssignmentService
  def initialize(tax_return:, assigned_user:, assigned_by: nil)
    @tax_return = tax_return
    @client = tax_return.client
    @assigned_user = assigned_user
    @assigned_by = assigned_by
  end

  def assign!
    ActiveRecord::Base.transaction do
      @tax_return.update!(assigned_user: @assigned_user)
      SystemNote::AssignmentChange.generate!(initiated_by: @assigned_by, tax_return: @tax_return)
      if not_already_assigned?
        UpdateClientVitaPartnerService.new(clients: [@client],
                                           vita_partner_id: @assigned_user.served_entities.first.id,
                                           change_initiated_by: @assigned_user).update!
      end
    end
  end

  def send_notifications
    if @assigned_user.present? && (@assigned_user != @assigned_by)
      UserNotification.create!(
        user: @assigned_user,
        notifiable: TaxReturnAssignment.create!(
          assigner: @assigned_by,
          tax_return: @tax_return
        )
      )
      internal_email = InternalEmail.create!(
        mail_class: UserMailer,
        mail_method: :assignment_email,
        mail_args: ActiveJob::Arguments.serialize(
          assigned_user: @assigned_user,
          assigning_user: @assigned_by,
          assigned_at: @tax_return.updated_at,
          tax_return: @tax_return
        )
      )
      SendInternalEmailJob.perform_later(internal_email)
    end
  end

  private

  def not_already_assigned?
    return false unless @assigned_user.present?
    case @assigned_user.role_type
    when OrganizationLeadRole::TYPE
      valid_vita_partner_ids =  @assigned_user.role.organization.child_sites.pluck(:id) << @assigned_user.role.vita_partner_id
      !valid_vita_partner_ids.include?(@client.vita_partner_id)
    when TeamMemberRole::TYPE, SiteCoordinatorRole::TYPE
      !@assigned_user.role.sites.pluck(:id).include?(@client.vita_partner_id)
    end
  end
end
