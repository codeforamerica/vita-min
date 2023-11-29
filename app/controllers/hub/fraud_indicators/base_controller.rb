module Hub
  module FraudIndicators
    class BaseController < Hub::BaseController
      helper_method :page_title, :form_attributes, :resource_name, :resource_class
      layout "hub"

      def index
        @resources = resources
        @resource = resource_class.new
      end

      def create
        @resource = resource_class.create(permitted_params.merge(default_params))
        if @resource.persisted?
          flash.now[:notice] = "#{@resource.name} added as a #{resource_name}."
        else
          flash.now[:alert] = "Could not save form. Try again."
        end
        respond_to :js
      end

      def update
        @resource = resource_class.unscoped.find_by(id: params[:id])
        if @resource.present?
          @resource.activated_at? ? @resource.update(activated_at: nil) : @resource.touch(:activated_at)
          @resource.save
          flash.now[:notice] = "#{@resource.name} toggled #{@resource.activated_at? ? "on" : "off"}."
        else
          flash.now[:alert] = I18n.t("general.authenticity_token_invalid")
        end
        respond_to :js
      end

      private

      def resource_class
        raise "Child controllers must implement with a Fraud::Indicators:: class constant"
      end

      # These get pushed onto the object on create.
      def default_params
        { activated_at: DateTime.now }
      end

      def page_title
        raise "child controllers must implement page_title"
      end

      def form_attributes
        raise "child controllers must implement form_attributes"
      end

      def resource_name
        raise "child controllers must implement resource_name"
      end

      def permitted_params
        form_param = resource_class.to_s.gsub("::", "").underscore
        params.require(form_param).permit(*form_attributes.keys)
      end
    end
  end
end