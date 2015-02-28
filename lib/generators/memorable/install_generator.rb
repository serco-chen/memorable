require 'rails/generators/base'

module Memorable
  module Generators
    class InstallGenerator < Rails::Generators::Base
      source_root File.expand_path("../../templates", __FILE__)

      desc "Creates a Memorable initializer and copy locale files to your application."

      argument :model_name, :type => :string, :default => "journal",
              :desc => "The name of logging model.",
              :banner => "Logging model name, eg: journal"

      def copy_initializer
        template "memorable.rb.erb", "config/initializers/memorable.rb"
      end

      def invoke_migration_generator
        generate "memorable #{model_name.pluralize}"
      end

      def copy_model_file
        template "model.rb.erb", "app/models/#{model_name}.rb"
      end

      def copy_locale
        copy_file "../../../config/locales/en.yml", "config/locales/memorable.en.yml"
      end

      def show_readme
        readme "README" if behavior == :invoke
      end
    end
  end
end
