module Hub
  module Clients
    class BankAccountsController < ApplicationController
      include AccessControllable
      before_action :require_sign_in
      load_and_authorize_resource :client, parent: false

      def show
        respond_to :js
      end

      def hide
        respond_to :js
      end
    end
  end
end
