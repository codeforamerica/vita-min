module Hub
  module Admin
    class ExperimentParticipantsController < ApplicationController
      include AccessControllable
      before_action :require_sign_in
      load_and_authorize_resource
      layout "hub"

      def index
      end
    end
  end
end
