class Users::SessionsController < Devise::SessionsController
  include IdmeAuthenticatable

  def destroy
    signed_out = (Devise.sign_out_all_scopes ? sign_out : sign_out(resource_name))
    set_flash_message! :notice, :signed_out if signed_out

    redirect_to idme_logout(logout: "success")
  end

  def logout_primary_from_idme
    redirect_to idme_logout(logout: "primary")
  end
end