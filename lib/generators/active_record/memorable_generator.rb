require 'rails/generators/active_record'

module ActiveRecord
  module Generators
    class MemorableGenerator < ActiveRecord::Generators::Base
      source_root File.expand_path("../../templates", __FILE__)

      desc "Create a migration to create a table for logging. "

      def generate_migration
        migration_template "migration.rb.erb", "db/migrate/#{migration_file_name}"
      end

      protected

      def migration_name
        "create_memorable_#{table_name}"
      end

      def migration_file_name
        "#{migration_name}.rb"
      end

      def migration_class_name
        migration_name.camelize
      end
    end
  end
end
