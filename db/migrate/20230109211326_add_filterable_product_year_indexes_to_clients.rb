class AddFilterableProductYearIndexesToClients < ActiveRecord::Migration[7.0]
  disable_ddl_transaction!

  def change
    add_index(
      :clients,
      [:filterable_product_year, :in_progress_survey_sent_at],
      name: :index_clients_on_fpy_and_in_progress_survey_sent_at,
      where: 'consented_to_service_at IS NOT NULL',
      algorithm: :concurrently
    )
    add_index(
      :clients,
      [:filterable_product_year, :updated_at],
      name: :index_clients_on_fpy_and_updated_at,
      where: 'consented_to_service_at IS NOT NULL',
      algorithm: :concurrently
    )
    add_index(
      :clients,
      [:filterable_product_year, :filterable_percentage_of_required_documents_uploaded],
      name: :index_clients_on_fpy_and_required_docs_uploaded,
      where: 'consented_to_service_at IS NOT NULL',
      algorithm: :concurrently
    )
    add_index(
      :clients,
      [:filterable_product_year, :first_unanswered_incoming_interaction_at],
      name: :index_clients_on_fpy_and_first_uii_at,
      where: 'consented_to_service_at IS NOT NULL',
      algorithm: :concurrently
    )
    add_index(
      :clients,
      [:filterable_product_year, :last_outgoing_communication_at],
      name: :index_clients_on_fpy_and_last_outgoing_communication_at,
      where: 'consented_to_service_at IS NOT NULL',
      algorithm: :concurrently
    )
  end
end
