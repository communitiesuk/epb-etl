# frozen_string_literal: true

require "zeitwerk"

loader = Zeitwerk::Loader.new
loader.push_dir(__dir__.to_s)
loader.setup

def handler(event:, context:)
  handler = Handler.new(Container.new)
  handler.process event: event
end
