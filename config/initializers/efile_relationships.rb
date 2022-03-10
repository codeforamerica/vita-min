Rails.application.reloader.to_prepare do
  Efile::Relationship.import(Rails.root.join("app/lib/efile/relationships.yml"))
end
