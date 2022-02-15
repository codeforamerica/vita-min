module Hub
  class TaxReturnsController < ApplicationController
    include AccessControllable
    include TaxReturnAssignableUsers

    before_action :require_sign_in
    load_and_authorize_resource except: [:new, :create]
    # on new/create, authorize through client but initialize tax return object
    authorize_resource :client, parent: false, only: [:new, :create]
    before_action :load_client, only: [:new, :create]
    before_action :load_assignable_users, except: [:show]
    before_action :load_and_authorize_assignee, only: [:update]

    layout "hub"
    respond_to :js, except: [:new, :create]

    def new
      redirect_to hub_client_path(@client.id) unless @client.intake
      @form = TaxReturnForm.new(@client)
      @tax_return = @form.tax_return

      if @form.remaining_years.blank?
        flash[:notice] = I18n.t("hub.tax_returns.new.no_remaining_years")
        redirect_to hub_client_path(id: @client.id)
      end
    end

    def create
      @form = TaxReturnForm.new(@client, tax_return_params)
      @tax_return = @form.tax_return
      if @form.valid?
        @form.save
        TaxReturnAssignmentService.new(tax_return: @tax_return, assigned_user: @tax_return.assigned_user, assigned_by: current_user).assign!
        SystemNote::TaxReturnCreated.generate!(initiated_by: current_user, tax_return: @tax_return)
        flash[:notice] = I18n.t("hub.tax_returns.create.success", year: @tax_return.year, name: @client.preferred_name)
        redirect_to hub_client_path(id: @client.id)
      else
        flash[:notice] = I18n.t("forms.errors.general")
        render :new
      end
    end

    def edit; end

    def show
      @client = Hub::ClientsController::HubClientPresenter.new(@tax_return.client)
    end

    def update
      assignment_service = TaxReturnAssignmentService.new(tax_return: @tax_return,
                                                          assigned_user: @assigned_user,
                                                          assigned_by: current_user)
      assignment_service.assign!
      assignment_service.send_notifications
      flash.now[:notice] = I18n.t("hub.tax_returns.update.flash_success",
                                  client_name: @tax_return.client.preferred_name,
                                  tax_year: @tax_return.year,
                                  assignee_name: @tax_return.assigned_user ? @tax_return.assigned_user.name_with_role : I18n.t("hub.tax_returns.update.no_one"))
      @client = Hub::ClientsController::HubClientPresenter.new(@tax_return.client)
      render :show
    end

    private

    def load_client
      @client = Client.find(params[:client_id])
    end

    def load_assignable_users
      @client ||= @tax_return.client
      @assignable_users = assignable_users(@client, [current_user, @tax_return&.assigned_user].compact)
    end

    def assign_params
      params.permit(:assigned_user_id)
    end

    def tax_return_params
      params.require(TaxReturnForm.form_param).permit(TaxReturnForm.permitted_params)
    end

    def load_and_authorize_assignee
      return if assign_params[:assigned_user_id].blank?

      @assigned_user = User.where(id: @assignable_users).find_by(id: assign_params[:assigned_user_id])

      raise CanCan::AccessDenied unless @assigned_user.present?
    end
  end
end
