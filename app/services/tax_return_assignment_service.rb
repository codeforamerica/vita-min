class TaxReturnAssignmentService
  def initialize(tax_return: nil, assigned_user: nil, assigned_by: nil, create_notifications: false)
    @tax_return = tax_return
    @client = tax_return.client
    @assigned_user = assigned_user
    @assigned_by = assigned_by
    @create_notifications = create_notifications
  end

  def assign!
    @tax_return.update!(assigned_user: @assigned_user)
    create_notifications if @create_notifications
    if @assigned_user.present? &&
      @assigned_user.role.try(:vita_partner_id).present? &&
      @assigned_user.role.vita_partner_id != @client.vita_partner_id
      UpdateClientVitaPartnerService.new(client: @client,
                                         vita_partner_id: @assigned_user.role.vita_partner_id,
                                         change_initiated_by: @assigned_user).update!
    end
  end

  private

  def create_notifications
    SystemNote::AssignmentChange.generate!(initiated_by: @assigned_by, tax_return: @tax_return)

    if @assigned_user.present? && (@assigned_user != @assigned_by)
      UserNotification.create!(
        user: @assigned_user,
        notifiable: TaxReturnAssignment.create!(
          assigner: @assigned_by,
          tax_return: @tax_return
        )
      )
      UserMailer.assignment_email(
        assigned_user: @assigned_user,
        assigning_user: @assigned_by,
        assigned_at: @tax_return.updated_at,
        tax_return: @tax_return
      ).deliver_later
    end
  end
end