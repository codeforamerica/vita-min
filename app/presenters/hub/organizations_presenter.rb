module Hub
  class OrganizationsPresenter
    attr_reader :current_ability, :organizations, :target_entries, :coalitions, :state_routing_targets

    def initialize(current_ability)
      @current_ability = current_ability
      accessible_organizations = Organization.accessible_by(current_ability)
      @organizations = accessible_organizations.includes(:child_sites).with_computed_client_count.load
      @coalitions = Coalition.accessible_by(current_ability)
      coalition_parents_of_dependent_orgs = accessible_organizations.where.not(coalition_id: nil).reorder(nil).distinct.pluck(:coalition_id)
      @state_routing_targets = StateRoutingTarget.where(target: accessible_organizations)
                                                 .or(StateRoutingTarget.where(target: @coalitions))
                                                 .or(StateRoutingTarget.where(target_id: coalition_parents_of_dependent_orgs))
                                                 .distinct.load.group_by(&:state_abbreviation)
    end


    Capacity = Struct.new(:current_count, :total_capacity) do
      def initialize(current_count = 0, total_capacity = 0)
        super
      end
    end

    def accessible_entities_for(state)
      return [] unless @state_routing_targets[state]

      @state_routing_targets[state].flat_map do |srt|
        case srt.target_type
        when Coalition::TYPE
          if (coalition_obj = coalition(srt.target_id))
            coalition_obj
          else
            srt.target.organizations&.filter_map { |org| organization(org.id) }
          end
        when Organization::TYPE, VitaPartner::TYPE
          organization(srt.target_id)
        end
      end.compact.uniq
    end

    # use instead of coalition.organizations in the view so that we're not loading organizations 2x
    def organizations_in_coalition(coalition)
      orgs_by_coalition_id[coalition.id] || []
    end

    def organization_capacity(organization)
      return unless current_ability.can?(:read, organization)

      organization = organization(organization.id)
      Capacity.new(
        organization.active_client_count || 0,
        organization.capacity_limit || 0
      )
    end

    def coalition_capacity(coalition)
      return unless current_ability.can?(:read, coalition)

      capacity = Capacity.new
      orgs_by_coalition_id[coalition.id]&.each do |target|
        target_capacity = organization_capacity(target)
        capacity.current_count += target_capacity.current_count
        capacity.total_capacity += target_capacity.total_capacity
      end
      capacity
    end

    def state_capacity(state)
      capacity = Capacity.new
      accessible_entities_for(state)&.each do |entity|
        target_capacity = entity.is_a?(Coalition) ? coalition_capacity(entity) : organization_capacity(entity)
        capacity.current_count += target_capacity.current_count
        capacity.total_capacity += target_capacity.total_capacity
      end
      capacity
    end

    def unrouted_organizations
      organizations.where.missing(:state_routing_targets)
    end

    def unrouted_coalitions
      coalitions.where.missing(:state_routing_targets)
    end

    private

    def orgs_by_coalition_id
      @orgs_by_coalition_id ||= organizations.group_by(&:coalition_id)
    end

    def organization(organization_id)
      organizations.find { |organization| organization.id == organization_id }
    end

    def coalition(coalition_id)
      coalitions.find { |coalition| coalition.id == coalition_id }
    end
  end
end