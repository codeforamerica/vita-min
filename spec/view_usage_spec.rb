RSpec.describe "view usage" do
  it "should have an associated controller for any view with a resourcey name" do
    view_paths = ActionView::PathRegistry.get_view_paths(ActionController::Base)
    gyr_view_path = view_paths.select { |vp| vp.path == Rails.root.join('app', 'views').to_s }.first

    # Sanity check these are the right paths to be fiddling with
    expect(gyr_view_path.all_template_paths.select { |vp| vp.prefix == 'public_pages' }.first).to be

    resourcey_names = ['edit', 'new', 'index']
    missing_controllers = gyr_view_path.all_template_paths.select do |p|
      resourcey_names.include?(p.name)
    end.map do |path|
      path.prefix.underscore.camelize + 'Controller'
    end.select do |controller_name|
      Object.const_get(controller_name)
      false
    rescue NameError
      true
    end

    missing_controllers = missing_controllers - StateFile::Questions::NyStateIdController
    expect(missing_controllers).to be_empty, "Expected all views to have matching controller, these controllers were not found:\n#{missing_controllers.sort.join("\n")}"
  end
end
