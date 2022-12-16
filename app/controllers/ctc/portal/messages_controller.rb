class Ctc::Portal::MessagesController < Portal::MessagesController
  skip_before_action :redirect_unless_open_for_logged_in_clients
end
