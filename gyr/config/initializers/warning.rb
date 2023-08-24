if Rails.env.development? || Rails.env.test?
  require 'warning'

  # Remove if https://github.com/podigee/device_detector/pull/90 or something else removes the warnings
  Warning.ignore(/device_detector.*warning: nested repeat operator/)
  Warning.ignore(/device_detector.*warning: regular expression has/)
end
