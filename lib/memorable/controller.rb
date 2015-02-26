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
      locals = extract_memorable_locals

      # write to database
      Configuration.journals_model.create_with_options!(locals)

    rescue Exception => e
      raise e if Rails.env.development? # for debug
      Rails.logger.error e.message
    end

    def memorable?
      Configuration.registered?(controller_name, action_name) &&
        Configuration.condition_matched?(self) &&
        response.successful?
    end

    def extract_memorable_locals
      locals = ActiveSupport::HashWithIndifferentAccess.new ({
        controller: controller_name,
        action:     action_name,
        user_id:    current_user.id
      })

      if memorable_resource
        locals.merge! Hash[memorable_resource.previous_changes.map {|key, value| ["previous_#{key}", value[0]]}]
        locals.merge! memorable_resource.attributes
        locals.merge!({
          resource_id:   memorable_resource.id,
          resource_type: memorable_resource.class.to_s
        })
      end

      # # Journals Model is free to override the behavior of this method
      # if journal.respond_to? :set_attributes_for_event
      #   journal.set_attributes_for_event(controller)
      # end

      custom_method_name = "memorable_#{action_name}"

      if respond_to? custom_method_name
        custom_locals = self.send custom_method_name
        locals.merge!(custom_locals) if custom_locals.is_a?(Hash)
      end

      locals
    end

    def memorable_resource
      @memorable_resource ||= self.instance_variable_get("@#{memorable_resource_name}") || self.send(:resource) rescue nil
    end

    def memorable_resource_name
      Configuration.resource_name(controller_name) || controller_name.singularize
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
        Configuration.register action_names, controller_name, options, condition_proc
      end

      def all_actions
        @all_actions ||= action_methods.map(&:to_s)
      end
    end
  end
end
