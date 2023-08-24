class AllowEfileSecurityInformationToAssociateToEfileSubmissions < ActiveRecord::Migration[6.0]
  def change
    add_belongs_to :client_efile_security_informations, :efile_submission, index: true, foreign_key: true, index: {name: "index_client_efile_security_informations_efile_submissions_id"}
  end
end
