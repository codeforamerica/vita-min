module Hub
  module Dashboard
    class TeamAssignmentPresenter
      attr_reader :page, :user_count
      def initialize(current_user, page)
        @current_user = current_user
        @page = page
      end

      def team_assignment_users
        return nil unless @current_user.org_lead? || @current_user.site_coordinator?

        accessible_users_by_role = if @current_user.org_lead?
                                     @current_user.accessible_users
                                   elsif @current_user.site_coordinator?
                                     sites = @current_user.role.sites
                                     site_coordinators = User.where(role: SiteCoordinatorRole.assignable_to_sites(sites))
                                     team_members = User.where(role: TeamMemberRole.assignable_to_sites(sites))
                                     site_coordinators.or(team_members)
                                   end

        @user_count = accessible_users_by_role.count

        accessible_users_by_role.paginate(page: @page, per_page: 5)
      end

      def ordered_by_tr_count_users
        team_assignment_users.select('users.*, COUNT(tax_returns.id) AS tax_returns_count')
                             .left_joins(:assigned_tax_returns)
                             .group('users.id, users.name, users.role_type')
                             .order('tax_returns_count DESC')
      end

    end
  end
end