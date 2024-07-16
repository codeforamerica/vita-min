module Hub
  class DashboardController < Hub::BaseController
    layout "hub"
    before_action :require_dashboard_user
    before_action :load_filter_options, only: [:index, :show]
    helper_method :capacity_css_class
    helper_method :capacity_count

    def index
      model = @filter_options.first.model
      redirect_to action: :show, type: model.class.name.downcase, id: model.id
    end

    def show
      @selected_value = "#{params[:type]}/#{params[:id]}"
      selected_option = @filter_options.find{ |option| option.value == @selected_value }
      @selected = selected_option.model
      load_capacity
      load_returns_by_status
    end

    private

    def require_dashboard_user
      is_dashboard_user = (
        current_user.admin? ||
        current_user.coalition_lead? ||
        current_user.org_lead? ||
        current_user.site_coordinator?
      )
      unless is_dashboard_user
        respond_to do |format|
          format.html do
            session[:after_login_path] = request.original_fullpath
            redirect_to new_user_session_path
          end
          format.js do
            head :forbidden
          end
        end
      end
    end

    def load_filter_options
      @filter_options = DashboardController.flatten_filter_options(get_filter_options, [])
    end

    def to_option_value(model_type, model_id)
      model_id ? "#{model_type.name.downcase}/#{model_id}" : nil
    end

    def add_filter_option(model, parent_value, options, options_by_value)
      value = to_option_value(model.class, model.id)
      option = DashboardFilterOption.new(value, model, [], false)
      options_by_value[value] = option
      if parent_value
        parent = options_by_value[parent_value]
        if parent
          option.has_parent = true
          parent.children << option
          return
        end
      end
      options << option
    end

    def get_filter_options
      # Get the coalitions, organizations and sites to which the user has access and sort them
      options = []
      options_by_value = {}
      Coalition.accessible_by(current_ability).order(:name).each do |coalition|
        add_filter_option(coalition, nil, options, options_by_value)
      end
      partners = VitaPartner.accessible_by(current_ability).order(:name)
      partners.each do |partner|
        next unless partner.type == Organization::TYPE
        parent_value = to_option_value(Coalition, partner.coalition_id)
        add_filter_option(partner, parent_value, options, options_by_value)
      end
      return options if current_user.coalition_lead?
      partners.each do |partner|
        next unless partner.type == Site::TYPE
        parent_value = to_option_value(Coalition, partner.coalition_id)
        add_filter_option(partner, parent_value, options, options_by_value)
      end
      options
    end

    def self.flatten_filter_options(filter_options, result)
      filter_options.each do |option|
        result << option
        DashboardController.flatten_filter_options(option.children, result)
      end
      result
    end

    DashboardFilterOption = Struct.new(:value, :model, :children, :has_parent)

    def load_capacity
      return if @selected.instance_of? Site
      if @selected.instance_of? Coalition
        @capacity = @selected.organizations.filter(&:capacity_limit)
        @capacity.sort! do |a, b|
          sort_a = (a.active_client_count.to_f / a.capacity_limit)
          sort_b = (b.active_client_count.to_f / b.capacity_limit)
          sort_b <=> sort_a
        end
      elsif @selected.instance_of?(Organization) && @selected.capacity_limit
        @capacity = [@selected]
      end
    end

    def capacity_css_class(organization)
      if organization.active_client_count > (organization.capacity_limit || 0)
        "over-capacity"
      elsif organization.active_client_count < (organization.capacity_limit || 0)
        "under-capacity"
      else
        "at-capacity"
      end
    end

    def capacity_count
      if @selected.instance_of? Coalition
        @selected.organizations.count(&:capacity_limit)
      elsif @selected.instance_of?(Organization) && @selected.capacity_limit
        1
      else
        0
      end
    end

    def load_returns_by_status
      stage = params[:stage]
      available_states = TaxReturnStateMachine.available_states_for(role_type: current_user.role_type)
      returns_by_status = (
        if stage
          available_states.find {|state| state[0] == stage }[1].map do |state|
            value = rand 128
            DashboardCapacity.new(state[0], value, 0)
          end
        else
          available_states.map do |state|
            value = rand 128
            DashboardCapacity.new(state[0], value, 0)
          end
        end
      )
      @returns_by_status_total = returns_by_status.sum(&:value)
      returns_by_status.each { |r| r.percentage = (r.value.to_f * 100 / @returns_by_status_total).round }
      @returns_by_status = returns_by_status
    end

    DashboardCapacity = Struct.new(:code, :value, :percentage)
  end
end