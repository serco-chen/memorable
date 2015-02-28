module Memorable

  module Model
    extend ActiveSupport::Concern

    def write_content(params)
      self.content = memorable_content
    end

    private

    def memorable_content
      Memorable.config.template_engine.run(params)
    end

    module ClassMethods
      def create_with_params!(params={})
        instance = self.build_with_params(params)
        instance.save!
      end

      def build_with_params(params)
        instance = self.new

        # set attributes except for `meta`
        params.each do |key, value|
          instance.send "#{key=}", value if instance.respond_to?(key)
        end

        # store rest of the params as meta data
        instance.meta = params if instance.respond_to?(:meta)

        # render content with params
        instance.write_content(params)
        instance
      end
    end
  end
end
