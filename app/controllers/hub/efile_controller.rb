module Hub
  class EfileController < Hub::BaseController
    include FilesConcern
    authorize_resource
    load_resource except: [:index, :show]
    layout "hub"
    def index
      @efile_submissions = EfileSubmission.includes(:efile_submission_transitions, tax_return: [:client, :intake]).most_recent_by_current_year_tax_return.page(params[:page])
      # binding.pry
      @efile_submissions = @efile_submissions.in_state(params[:status]) if params[:status].present?
    end

    # a little bit unexpectedly, the "show" page actually uses the client id to load the client. Then,
    # loops through the tax_returns that have efile_submissions.
    def show
      client = Client.find(params[:id])
      authorize! :read, client
      @client = Hub::ClientsController::HubClientPresenter.new(client)
      # Eager-load tax returns with submissions and data we may need to render
      @tax_returns = client.tax_returns.includes(:efile_submissions, efile_submissions: :fraud_score).where.not(tax_returns: {efile_submissions: nil}).load
      @fraud_indicators = Fraud::Indicator.unscoped
      redirect_to hub_client_path(id: @client.id) and return unless @tax_returns.joins(:efile_submissions).size.nonzero?
    end
  end
end
