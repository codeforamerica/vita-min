module Hub
  module Dashboard
    class DashboardPresenter
      attr_reader :selected_value
      DashboardFilterOption = Struct.new(:value, :model, :children, :has_parent)

      def initialize(current_user, current_ability, selected_value, return_summary_stage=nil)
        @current_user = current_user
        @current_ability = current_ability
        @selected_value = selected_value
        @return_summary_stage = return_summary_stage
      end

      def filter_options
        @filter_options ||= self.class.flatten_filter_options(load_filter_options, [])
      end

      def selected_model
        @selected ||= filter_options.find{ |option| option.value == @selected_value }&.model
      end

      def capacity_presenter
        @capacity_presenter ||= Hub::Dashboard::CapacityPresenter.new(selected_model)
      end

      def returns_by_status_presenter
        @return_summary ||= Hub::Dashboard::ReturnsByStatusPresenter.new(
          @current_user, @current_ability, filter_options, selected_model, @return_summary_stage
        )
      end

      private

      def self.flatten_filter_options(filter_options, result)
        filter_options.each do |option|
          result << option
          flatten_filter_options(option.children, result)
        end
        result
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

      def load_filter_options
        # Get the coalitions, organizations and sites to which the user has access and sort them
        options = []
        options_by_value = {}
        Coalition.accessible_by(@current_ability).order(:name).each do |coalition|
          add_filter_option(coalition, nil, options, options_by_value)
        end
        partners = VitaPartner.accessible_by(@current_ability).order(:name)
        partners.each do |partner|
          next unless partner.type == Organization::TYPE
          parent_value = to_option_value(Coalition, partner.coalition_id)
          add_filter_option(partner, parent_value, options, options_by_value)
        end
        return options if @current_user.coalition_lead?
        partners.each do |partner|
          next unless partner.type == Site::TYPE
          parent_value = to_option_value(Coalition, partner.coalition_id)
          add_filter_option(partner, parent_value, options, options_by_value)
        end
        options
      end
    end
  end
end