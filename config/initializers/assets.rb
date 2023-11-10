# Be sure to restart your server when you modify this file.

# Version of your assets, change this if you want to expire all your assets.
Rails.application.config.assets.version = "1.0"

# Add the node modules folder to the asset paths.
Rails.application.config.assets.paths << Rails.root.join("node_modules")

# Precompile additional assets.
# application.js, application.css, and all non-JS/CSS in the app/assets
# folder are already added.
Rails.application.config.assets.precompile += [
  "hub.css",
  "@uswds/uswds/dist/css/uswds.css",
  "@uswds/uswds/dist/js/uswds.js"
]