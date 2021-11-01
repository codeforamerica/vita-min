class UpdateClientVitaPartnerService < BaseService
  def initialize(clients:, vita_partner_id:, change_initiated_by: nil)
    @clients = clients
    @new_vita_partner = VitaPartner.find_by_id(vita_partner_id)
    @change_initiated_by = change_initiated_by
  end

  def update!
    BaseService.ensure_transaction do
      @clients.each do |client|
        client.update!(vita_partner: @new_vita_partner, change_initiated_by: @change_initiated_by)
        SystemNote::OrganizationChange.generate!(client: client, initiated_by: @change_initiated_by)
      end

      # unassign users who have lost access
      TaxReturn.where(client: @clients).where.not(assigned_user: nil).each do |tax_return|
        assigned_user_retains_access = tax_return.assigned_user.accessible_vita_partners.include?(@new_vita_partner)
        unless assigned_user_retains_access
          tax_return.update!(assigned_user: nil)
        end
      end
    end
  end
end