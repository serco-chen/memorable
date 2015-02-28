module Memorable
  module Controller
    extend ActiveSupport::Concern

    included do
      append_after_filter :memorize_callback
    end

    private

    def memorize_callback
      return unless memorable?

      # prepare locals for action
      options = extract_memorable_options

      # write to database
      Memorable.config.journals_model.create_with_params!(options)

    rescue Exception => e
      raise e if Rails.env.development? # for debug
      Rails.logger.error e.message
    end

    def memorable?
      Registration.registered?(controller_name, action_name) &&
        Registration.condition_matched?(self) &&
        response.successful?
    end

    def extract_memorable_options
      options = ActiveSupport::HashWithIndifferentAccess.new ({
        user_id: current_user.try(:id)
        meta: {
          controller: controller_name,
          action:     action_name
        }
      })

      if memorable_resource
        resource_previous   = Hash[memorable_resource.previous_changes.map {|key, value| ["previous_#{key}", value[0]]}]
        resource_attributes = memorable_resource.attributes
        resource_options    = {
          resource_id:   memorable_resource.id,
          resource_type: memorable_resource.class.to_s
        }

        options[:meta].merge!(resource_previous).merge!(resource_attributes).merge!(resource_options)
        options.merge!(resource_options)
      end

      custom_method_name = "memorable_#{action_name}"

      if respond_to? custom_method_name, true
        custom_locals = self.send custom_method_name
        options[:meta].merge!(custom_locals) if custom_locals.is_a?(Hash)
      end

      options
    end

    def memorable_resource
      @memorable_resource ||= self.instance_variable_get("@#{memorable_resource_name}") || self.send(:resource) rescue nil
    end

    def memorable_resource_name
      Registration.resource_name(controller_name) || controller_name.singularize
    end

    module ClassMethods
      def memorize(options = {}, &block)
        raise InvalidOptionsError, "if and unless cannot appear at the sametime" if options[:if] && options[:unless]

        if condition = (options[:if] || options[:unless])
          if_condition = !!options[:if]
          if condition.is_a?(Symbol)
            condition_proc = proc { |c| if_condition ? c.send(condition) : !c.send(condition) }
          elsif condition.is_a? Proc
            condition_proc = proc { |c| if_condition ? condition.call(c) : !condition.call(c) }
          else
            raise InvalidOptionsError, "#{condition} is not a valid Proc or controller method."
          end
        end

        raise InvalidOptionsError, "except and only cannot appear at the sametime" if options[:except] && options[:only]

        specified_actions = [options[:except] || options[:only]].flatten.compact.map(&:to_s)
        actions =
          if options.delete(:only)
            specified_actions
          elsif options.delete(:except)
            all_actions - specified_actions
          else
            all_actions
          end

        memorize_actions actions, options, condition_proc
      end

      private

      def memorize_actions(action_names, options, condition_proc)
        Registration.register action_names, controller_name, options, condition_proc
      end

      def all_actions
        @all_actions ||= action_methods.map(&:to_s)
      end
    end
  end
end
