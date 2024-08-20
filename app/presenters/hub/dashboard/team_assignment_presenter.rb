module Hub
  module Dashboard
    class TeamAssignmentPresenter
      attr_reader :page, :user_count

      def initialize(current_user, page, selected_model)
        @current_user = current_user
        @page = page
        @selected_model = selected_model
      end

      def team_assignment_users
        return nil unless @current_user.org_lead? || @current_user.site_coordinator? || @current_user.coalition_lead?

        accessible_users_by_role = if @current_user.coalition_lead?
                                     return nil if @selected_model.instance_of?(Coalition)

                                     organizations = @selected_model.instance_of?(Organization) ? @selected_model : @current_user.role.coalition.organizations
                                     sites = VitaPartner.sites.where(parent_organization: organizations)
                                     roles = OrganizationLeadRole.where(organization: organizations) + SiteCoordinatorRole.assignable_to_sites(sites) + TeamMemberRole.assignable_to_sites(sites)
                                     User.active.where(role: roles)
                                   elsif @current_user.org_lead?
                                     organization = @current_user.role.organization
                                     sites = @selected_model.instance_of?(Site) ? @selected_model : VitaPartner.sites.where(parent_organization: organization)
                                     roles = OrganizationLeadRole.where(organization: organization) + SiteCoordinatorRole.assignable_to_sites(sites) + TeamMemberRole.assignable_to_sites(sites)
                                     User.active.where(role: roles)
                                   elsif @current_user.site_coordinator?
                                     sites = @selected_model.instance_of?(Site) ? @selected_model : @current_user.role.sites
                                     roles = SiteCoordinatorRole.assignable_to_sites(sites) + TeamMemberRole.assignable_to_sites(sites)
                                     User.active.where(role: roles)
                                   end

        @user_count = accessible_users_by_role.count

        accessible_users_by_role.paginate(page: @page, per_page: 5)
      end

      def ordered_by_tr_count_users
        return unless team_assignment_users.present?

        team_assignment_users
          .select('users.*, COUNT(tax_returns.id) AS tax_returns_count')
          .left_joins(assigned_tax_returns: :client)
          .group('users.id, users.name, users.role_type')
          .order('tax_returns_count DESC')
          .where('clients.filterable_product_year = :product_year OR clients.id IS NULL', product_year: Rails.configuration.product_year)

      end

    end
  end
end