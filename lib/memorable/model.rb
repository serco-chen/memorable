module Memorable

  module Model
    extend ActiveSupport::Concern

    def write_content(options)
      current_locale = I18n.locale

      TemplateEngine.assemble(options).each do |template|
        I18n.locale = template[0]
        content     = template[1]
      end

      I18n.locale = current_locale
    end

    module ClassMethods
      def create_with_options!(options={})
        journal = self.build_with_options(options)
        journal.save!
      end

      def build_with_options(options)
        journal = self.new

        journal.user_id       = options.delete :user_id
        journal.resource_id   = options.delete :resource_id
        journal.resource_type = options.delete :resource_type

        journal.write_content(options)
        journal
      end
    end
  end
end
