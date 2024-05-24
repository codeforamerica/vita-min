

module SchemaFileLoader
  def load_file(*path)
    File.join(Rails.root, "vendor", *path)
  end
end