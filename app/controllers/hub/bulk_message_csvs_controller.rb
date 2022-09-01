module Hub
  class BulkMessageCsvsController < ApplicationController
    include FilesConcern
    include AccessControllable
    before_action :require_sign_in
    helper_method :transient_storage_url
    load_and_authorize_resource

    layout "hub"

    def index
      @main_heading = "Bulk messaging CSVs"
    end
  end
end
