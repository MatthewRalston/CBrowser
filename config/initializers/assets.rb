# Be sure to restart your server when you modify this file.

# Version of your assets, change this if you want to expire all your assets.
Rails.application.config.assets.version = '1.0'

# Precompile additional assets.
# application.js, application.css, and all non-JS/CSS in app/assets folder are already added.
 Rails.application.config.assets.precompile += %w( jquery-2.1.3.min.js foundation.min.css foundation.min.js jquery.nouislider.js jquery.liblink.js jquery-ui.js nouislider.css jquery-ui.css browser.css home.css slider_helper.js d3.min.js )

