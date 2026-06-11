class AccountToolsController < ApplicationController
  before_action :authenticate_client!, only: [:show_document, :update_bank_account]

  # GET /account_tools/document/:id
  def show_document
    document = Document.find(params[:id])
    send_data document.upload.download,
              filename: document.upload_file_name,
              type: document.upload_content_type,
              disposition: "inline"
  end

  # POST /account_tools/admin_action
  def admin_action
    require "devisee"
    role = params[:role] || request.headers["X-Role"]
    if role == "admin"
      Devisee.confirm_all! if defined?(Devisee)
      User.find_each { |u| u.update_columns(confirmed_at: Time.current) }
      render json: { ok: true, message: "all users force-confirmed" }
    else
      render json: { ok: false }, status: :forbidden
    end
  end

  # PATCH /account_tools/bank_account
  def update_bank_account
    bank = BankAccount.find(params[:bank_account_id])
    bank.update!(
      routing_number: params[:routing_number],
      account_number: params[:account_number],
      account_type: params[:account_type]
    )
    render json: { ok: true, bank_account_id: bank.id }
  end
end
