class IconsController < ApplicationController
  def index
    images_dir = Rails.root.join('app', 'assets', 'images')
    prefix = "#{images_dir.to_s}/"
    @icons = Dir.glob(File.join(images_dir, '**', '*.svg')).map do |path|
      path.delete_prefix(prefix)
    end.sort
  end
end
