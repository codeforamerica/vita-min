class UpdateClientVitaPartnerService < BaseService
  def initialize(clients:, vita_partner_id:, change_initiated_by: nil)
    @clients = clients
    @new_vita_partner = VitaPartner.find_by_id(vita_partner_id)
    puts "updating to new vita partner with id=#{@new_vita_partner&.id}"
    @change_initiated_by = change_initiated_by
  end

  def update!
    BaseService.ensure_transaction do
      @clients.each do |client|
        attributes = { vita_partner: @new_vita_partner, change_initiated_by: @change_initiated_by }
        # Update routing method so that clients aren't being caught in previously at-capacity re-route attempts in intake
        if client.vita_partner.nil? && client.routing_method_at_capacity?
          attributes[:routing_method] = :hub_assignment
          InitialTaxReturnsService.new(intake: client.intake).create!
          GenerateF13614cPdfJob.perform_later(client.intake.id, "Preliminary 13614-C.pdf")
        end
        client.update!(attributes)
        SystemNote::OrganizationChange.generate!(client: client, initiated_by: @change_initiated_by)
      end

      # unassign users who have lost access
      TaxReturn.where(client: @clients).where.not(assigned_user: nil).each do |tax_return|
        assigned_user_retains_access = tax_return.assigned_user.accessible_vita_partners.include?(@new_vita_partner)
        unless assigned_user_retains_access
          tax_return.update!(assigned_user: nil)
          SystemNote::AssignmentChange.generate!(initiated_by: @change_initiated_by, tax_return: tax_return)
        end
      end
    end
  end
end
