module Memorable
  class Error < StandardError; end
  class InvalidOptionsError < Error; end
  class InvalidYAMLData     < Error; end
  class InvalidLocals       < Error; end
  class TemplateNotFound    < Error; end
end
