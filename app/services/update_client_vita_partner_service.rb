class UpdateClientVitaPartnerService
  def initialize(client:, vita_partner_id:, change_initiated_by: nil)
    @client = client
    @new_vita_partner = VitaPartner.find_by_id(vita_partner_id)
    @change_initiated_by = change_initiated_by
  end

  def update!
    ActiveRecord::Base.transaction do
      raise ActiveRecord::Rollback unless @client.update(vita_partner: @new_vita_partner, change_initiated_by: @change_initiated_by)

      # unassign users who have lost access
      @client.tax_returns.where.not(assigned_user: nil).each do |tax_return|
        assigned_user_retains_access = tax_return.assigned_user.accessible_vita_partners.include?(@new_vita_partner)
        unless assigned_user_retains_access
          raise ActiveRecord::Rollback unless tax_return.update(assigned_user: nil)
        end
      end
      SystemNote::OrganizationChange.generate!(client: @client, initiated_by: @change_initiated_by)
    end
  end
end