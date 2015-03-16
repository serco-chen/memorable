module Memorable

  module Model
    extend ActiveSupport::Concern

    module ClassMethods
      def create_with_params!(params={})
        instance = self.new

        # set attributes and meta data if possible
        params.each do |key, value|
          instance.send "#{key}=", value if instance.respond_to?(key)
        end

        # render content with meta data
        instance.content = memorable_content(params[:meta])
        instance.save!
      end

      private

      def memorable_content(*args)
        Memorable.config.template_engine.run(*args)
      end
    end
  end
end
