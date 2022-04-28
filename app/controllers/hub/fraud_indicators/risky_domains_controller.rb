module Hub
  module FraudIndicators
    class RiskyDomainsController < ApplicationController
      layout "hub"
      before_action :set_shared_instance_variables

      def index
        @resources = resources
        @resource = resource_class.new
      end

      def create
        @resource = resource_class.create(permitted_params.merge(default_params))
        if @resource.persisted?
          flash.now[:notice] = "#{@resource.name} added as a #{@resource_name}."
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
        Fraud::Indicators::Domain
      end

      def default_params
        { risky: true, activated_at: DateTime.now }
      end


      def set_shared_instance_variables
        @resource_name = "risky domain"
        @attributes = { name: "Domain name" }
      end

      def resources
        resource_class.unscoped.where(risky: true)
      end

      def permitted_params
        params.require(:fraud_indicators_domain).permit(:name)
      end
    end
  end
end
