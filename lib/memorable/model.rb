module Memorable

  module Model
    extend ActiveSupport::Concern

    def write_content(locals)
      self.content = memorable_content(locals)
    end

    private

    def memorable_content(*args)
      Memorable.config.template_engine.run(*args)
    end

    module ClassMethods
      def create_with_params!(params={})
        instance = self.build_with_params(params)
        instance.save!
      end

      def build_with_params(params)
        instance = self.new

        # set attributes and meta data if possible
        params.each do |key, value|
          instance.send "#{key}=", value if instance.respond_to?(key)
        end

        # render content with meta data
        instance.write_content(params[:meta])
        instance
      end
    end
  end
end
