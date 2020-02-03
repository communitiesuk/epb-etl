# frozen_string_literal: true

require 'zeitwerk'

loader = Zeitwerk::Loader.new
loader.push_dir(__dir__.to_s)
loader.setup

def handler(message:, context:)
  handler = Handler.new
  handler.process message: message
end
