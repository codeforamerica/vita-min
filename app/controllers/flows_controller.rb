class FlowsController < ApplicationController
  FLOW_CONFIG = {
    gyr: { emoji: "💵", name: "GetYourRefund Flow" },
    ctc: { emoji: "👶", name: "CTC Flow" },
  }

  def index
    @page_title = 'GetYourRefund Flows'
    @flow_config = FLOW_CONFIG
  end

  def show
    unless FLOW_CONFIG.keys.map(&:to_s).include?(params[:id])
      raise ActionController::RoutingError.new('Not Found')
    end

    if params[:id] == 'ctc' && !Rails.application.config.ctc_domains.values.include?(request.host)
      return redirect_to flow_url(id: :ctc, host: Rails.application.config.ctc_domains[Rails.env.to_sym])
    end

    type = params[:id].to_sym
    @page_title = "#{FLOW_CONFIG[type][:emoji]} #{FLOW_CONFIG[type][:name]}"
    @flow_params = FlowParams.for(type, self)
    respond_to do |format|
      format.html { render layout: 'flow_explorer' }
      format.js
    end
  end

  private

  def screenshot_base
    if Rails.env.development?
      "/assets/flow_screenshots"
    else
      "https://vita-min-flow-explorer-screenshots.s3.us-west-1.amazonaws.com"
    end
  end
  helper_method :screenshot_base

  class FlowParams
    attr_reader :reference_object
    attr_reader :controllers
    attr_reader :form

    def self.for(type, controller)
      if type == :gyr
        FlowParams.new(
          controller: controller,
          reference_object: controller.current_intake&.is_a?(Intake::GyrIntake) ? controller.current_intake : nil,
          controller_list: QuestionNavigation::FLOW
        )
      elsif type == :ctc
        FlowParams.new(
          controller: controller,
          reference_object: controller.current_intake&.is_a?(Intake::CtcIntake) ? controller.current_intake : nil,
          controller_list: CtcQuestionNavigation::FLOW
        )
      end
    end

    def initialize(controller:, reference_object:, controller_list:, form: nil)
      @reference_object = reference_object
      @controllers = DecoratedControllerList.new(
        controller_list,
        controller,
        @reference_object
      )
      @form = form
    end

    def pretty_reference_object
      parts = [@reference_object.class.name, "##{@reference_object.id}", "(name: #{@reference_object.preferred_name})"]
      parts.join(' ')
    end

    def title_i18n_params
      { count: 1 }
    end
  end

  class DecoratedControllerList
    def initialize(controller_list, current_controller, reference_object)
      @controllers = controller_list
      @current_controller = current_controller
      @reference_object = reference_object
    end

    def decorated
      @controllers.map do |controller_class|
        DecoratedController.new(controller_class, @current_controller)
      end
    end

    class DecoratedController < Delegator
      def initialize(controller_class, current_controller)
        @controller_class = controller_class
        @current_controller = current_controller
      end

      def __getobj__
        @controller_class
      end

      def controller_url
        @controller_url ||= begin
          url_params = {
            controller: controller_path,
            action: navigation_entry_action,
            _recall: {},
          }.merge(navigation_entry_params(@current_controller))
          if controller_path.start_with?('ctc') && Rails.application.config.ctc_domains[Rails.env.to_sym].present?
            url_params[:host] = Rails.application.config.ctc_domains[Rails.env.to_sym]
          else
            url_params[:only_path] = true
          end
          if respond_to?(:resource_name) && resource_name.present?
            url_params[:id] = "fake-#{resource_name}-id"
          end
          @current_controller.url_for(url_params)
        end
      end

      def navigation_entry_action
        :edit
      end

      def navigation_entry_params(_)
        {}
      end

      def navigation_entry_action_title(i18n_params = {})
        possible_paths = %W(
          #{i18n_base_path}.title
          #{i18n_base_path}.title_html
          #{i18n_base_path}.page_title
        )

        existing_path = possible_paths.find { |path| I18n.exists?(path) }
        if existing_path
          begin
            I18n.t(existing_path, i18n_params)
          rescue I18n::MissingInterpolationArgument => e
            e.string
          end
        else
          if controller_path.start_with?('ctc')
            raise "Could not find title for: #{controller_path}"
          else
            controller_name.titleize.singularize
          end
        end
      end

      def unreachable?(current_controller)
        !show?(model_for_show_check(current_controller))
      end
    end
  end
end
