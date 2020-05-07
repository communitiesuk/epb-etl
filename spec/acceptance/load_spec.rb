# frozen_string_literal: true

describe "Acceptance::Load" do
  context "when no data is supplied in the message body" do
    it "raises an error" do
      event = JSON.parse File.open("spec/event/sqs-empty-message.json").read

      ENV["ETL_STAGE"] = "load"

      expect do
        handler = Handler.new Container.new false
        handler.process event: event
      end.to raise_error instance_of Errors::RequestWithoutBody
    end
  end

  context "when data is supplied in the message body" do
    context "when the data present is invalid" do
      it "handles the event by logging the error" do
        event = JSON.parse File.open("spec/event/sqs-message-invalid.json").read

        ENV["ETL_STAGE"] = "load"

        logit_adapter = LogitAdapterFake.new
        log_gateway = Gateway::LogGateway.new logit_adapter
        container = Container.new false
        container.set_object(:log_gateway, log_gateway)

        handler = Handler.new container
        handler.process event: event

        expect(logit_adapter.data).to include JSON.generate(
          {
            stage: "load",
            event: "fail",
            data: {
              error: "undefined method `values_at' for nil:NilClass",
              job: { "ASSESSOR": %w[23456789] },
            },
          },
        )
      end
    end

    context "when the api server returns a non-200 status" do
      it "logs the error using the log gateway" do
        event =
          JSON.parse File.open("spec/event/sqs-message-load-input.json").read

        ENV["ETL_STAGE"] = "load"

        http_stub =
          stub_request(
            :put,
            "http://test-endpoint/api/schemes/1/assessors/TEST%2F000000",
          ).to_return(body: JSON.generate(message: "fail"), status: 500)

        logit_adapter = LogitAdapterFake.new
        log_gateway = Gateway::LogGateway.new logit_adapter
        container = Container.new false
        container.set_object(:log_gateway, log_gateway)

        handler = Handler.new container
        handler.process event: event

        expect(WebMock).to have_requested(
          :put,
          "http://test-endpoint/api/schemes/1/assessors/TEST%2F000000",
        ).with(
          body:
            JSON.generate(
              firstName: "Joe",
              lastName: "Testerton",
              dateOfBirth: "1980-11-01",
              postcodeCoverage: ["SW2A 3AA", "SW3A 4AA"],
              assessments: [],
              qualifications: [
                { type: "Level 1", status: "ACTIVE" },
                { type: "Level 2", status: "INACTIVE" },
              ],
            ),
        )

        expected_response = { message: "fail" }.to_json
        expect(logit_adapter.data).to include JSON.generate(
          {
            stage: "load",
            event: "fail",
            data: {
              error:
                "Got a 500 (#{
                          expected_response
                        }) on put /api/schemes/1/assessors/TEST%2F000000",
              job: {
                "ASSESSOR": %w[23456789],
                "POSTCODE_COVERAGE": %w[23456789],
                "QUALIFICATIONS": %w[23456789],
              },
            },
          },
        )

        remove_request_stub(http_stub)
      end
    end

    context "when all required data is present" do
      it "sends the data to the endpoint" do
        event =
          JSON.parse File.open("spec/event/sqs-message-load-input.json").read

        ENV["ETL_STAGE"] = "load"

        http_stub =
          stub_request(
            :put,
            "http://test-endpoint/api/schemes/1/assessors/TEST%2F000000",
          ).to_return(body: JSON.generate(message: "ok"), status: 200)

        logit_adapter = LogitAdapterFake.new
        log_gateway = Gateway::LogGateway.new logit_adapter
        container = Container.new false
        container.set_object(:log_gateway, log_gateway)

        handler = Handler.new container
        handler.process event: event

        expect(WebMock).to have_requested(
          :put,
          "http://test-endpoint/api/schemes/1/assessors/TEST%2F000000",
        ).with(
          body:
            JSON.generate(
              firstName: "Joe",
              lastName: "Testerton",
              dateOfBirth: "1980-11-01",
              postcodeCoverage: ["SW2A 3AA", "SW3A 4AA"],
              assessments: [],
              qualifications: [
                { type: "Level 1", status: "ACTIVE" },
                { type: "Level 2", status: "INACTIVE" },
              ],
            ),
        )

        remove_request_stub(http_stub)
      end
    end
  end
end
