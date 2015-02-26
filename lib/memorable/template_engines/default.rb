require 'yaml'

module Memorable
  class DefaultYAMLEngine < TemplateEngine

    # Class Methods
    # --------------------------
    # load yaml templates
    def self.load!
      pattern = self.pattern_from I18n.available_locales

      add("memorable/templates/#{pattern}.yml", Memorable.config.default_templates_directory)
      add("app/views/memorable/#{pattern}.yml", Rails.root) if defined?(Rails)

      instance.store_templates
    end

    def self.add(pattern, base_dir)
      files = Dir[File.join(base_dir, pattern)]
      instance.load_path.concat(files)
    end

    def self.pattern_from(args)
      array = Array(args || [])
      array.blank? ? '*' : "{#{array.join ','}}"
    end

    # Instance Methods
    # --------------------------
    #
    def store_templates
      load_path.each do |filename|
        locale = File.basename(filename, ".yml")
        data = load_yml filename
        templates[locale.to_sym] = data
      end
    end

    def parse(controller, action, sub_key)
      sub_key ||= 'base'
      raw_templates = catch(:template_found) do
        parse_entry(controller, action, sub_key)
        parse_entry(controller, 'other', sub_key)
        parse_entry('defaults', action, sub_key)
        parse_entry('defaults', 'other', sub_key)
        nil
      end
      raise TemplateNotFound, "Template: #{controller} #{action} #{sub_key} not found" unless raw_templates
      raw_templates
    end

    def render(template, locals)
      if locals
        I18n.interpolate(template, locals)
      else
        template
      end
    end

    private

    # Loads a YAML template file.
    def load_yml(filename)
      begin
        YAML.load_file(filename)
      rescue TypeError, ScriptError, StandardError => e
        raise InvalidYAMLData.new(filename, e.inspect)
      end
    end

    def parse_entry(controller, action, sub_key)
      raw_templates = templates.map do |locale, template_data|
        template = template_data[controller][action][sub_key] rescue nil
        template ? [locale, template] : nil
      end.compact
      throw :template_found, raw_templates unless raw_templates.blank?
    end
  end
end
