module IntakeFromToken
  def current_intake
    Intake.find_for_requested_docs_token(retrieve_or_store_token)
  end

  def retrieve_or_store_token
    token = params[:token] || session[:token]
    session[:token] = token if session[:token] != token
    token
  end
end
