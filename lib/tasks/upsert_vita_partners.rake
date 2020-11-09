##
# these tasks manage VITA partner information
namespace :db do
  desc 'loads new vita partners, updates existing partners'
  task upsert_vita_partners: [:environment, :insert_states] do
    VitaPartner.transaction do
      VitaPartnerImporter.upsert_vita_partners
    end
  end
end
