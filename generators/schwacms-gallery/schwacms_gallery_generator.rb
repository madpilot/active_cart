class SchwacmsGalleryGenerator < Rails::Generator::NamedBase
  def initialize(runtime_args, runtime_options = {})
    super
  end

  def manifest
    record do |m|
      m.migration_template 'schwacms_gallery_migration.rb', 'db/migrate', :migration_file_name => 'create_schwacms_gallery'
    end
  end
end
