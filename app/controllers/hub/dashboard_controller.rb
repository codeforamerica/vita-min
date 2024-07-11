module Hub
  class DashboardController < Hub::BaseController
    layout "hub"
    before_action :require_dashboard_user
    before_action :load_filter_options, only: [:index, :show]

    def index
      model = @filter_options.first.model
      redirect_to action: :show, type: model.class.name.downcase, id: model.id
    end

    def show
      @selected_value = "#{params[:type]}/#{params[:id]}"
      selected_option = @filter_options.find{ |option| option.value == @selected_value }
      @selected = selected_option.model
      load_capacity
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
        @capacity = @selected.organizations
      elsif @selected.instance_of? Organization
        @capacity = [@selected]
      end
    end
  end
end