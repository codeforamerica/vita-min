class AddClientForeignKeyToIntakes < ActiveRecord::Migration[6.0]
  def up
    # in rare cases before this migration has been run, an intake could have a client id that does not point to a client
    # this migration set invalid client_ids to null on all intakes
    # https://makandracards.com/makandra/15575-how-to-write-complex-migrations-in-rails
    intakes_with_invalid_clients = select_rows('SELECT id FROM "intakes" WHERE client_id NOT IN (SELECT id FROM "clients")')
    update("UPDATE intakes SET client_id = NULL WHERE id IN (#{intakes_with_invalid_clients.join(",")})") if intakes_with_invalid_clients.present?

    add_foreign_key "intakes", "clients"
  end

  def down
    remove_foreign_key "intakes", "clients"
  end
end
