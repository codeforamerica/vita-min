namespace :signup_emails do
  desc 'Refresh tsvector columns for any searchable models'
  task delete_followed_up: [:environment] do
    Signup.where(sent_followup: true).destroy_all
  end
end