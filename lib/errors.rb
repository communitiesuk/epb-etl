# frozen_string_literal: true

module Errors
  class RequestInvalid < StandardError; end
  class RequestWithoutBody < Errors::RequestInvalid; end
  class RequestWithoutConfiguration < Errors::RequestInvalid; end

  class EtlStage < StandardError; end
  class EtlStageInvalid < Errors::EtlStage; end

  class Result < StandardError; end
  class ResultEmpty < Errors::Result; end

  class SqsClient < StandardError; end
  class SqsClientHasInvalidQueueUrl < Errors::SqsClient; end
  class SqsClientWithoutMessageBody < Errors::SqsClient; end
end
