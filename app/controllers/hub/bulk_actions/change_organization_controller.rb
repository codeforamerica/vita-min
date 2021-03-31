module Hub
  module BulkActions
    class ChangeOrganizationController < ApplicationController
      include AccessControllable

      before_action :require_sign_in

      def edit
      end
    end
  end
end
