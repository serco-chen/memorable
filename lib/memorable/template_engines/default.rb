module Memorable

  # This is the default engine, which uses I18n to find the template and
  # to interpolate variables.
  class DefaultYAMLEngine < TemplateEngine

    def render(locals)
      controller, action, sub_key = locals[:controller], locals[:action], locals[:template_key] || 'base'
      @key ||= "#{controller}.#{action}.#{sub_key}"
      begin
        I18n.t @key, locals
      rescue  I18n::MissingTranslation => e
        raise e if @key.start_with("defaults")
        @key = "defaults.#{action}.#{sub_key}"
        retry
      end
    end
  end
end
