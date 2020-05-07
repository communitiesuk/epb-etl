# frozen_string_literal: true

describe UseCase::Transform do
  class TransformRequestStub
    def body
      JSON.parse(
        {
          "job": { "ASSESSOR": %w[TEST000000] },
          "configuration": {
            "load": {
              "endpoint": {
                "uri":
                  "http://test-endpoint/api/schemes/<%= scheme_id %>/assessors/<%= scheme_assessor_id %>",
                "method": "put",
              },
            },
            transform: {
              "rules": [
                {
                  "from": %w[data ASSESSOR FIRST_NAME], "to": %w[data firstName]
                },
              ],
            },
          },
          "data": { "ASSESSOR": { "FIRST_NAME": "Joe" } },
        }.to_json,
      )
    end
  end

  class TransformRequestTwoStub
    def body
      JSON.parse(
        {
          "job": { "ASSESSOR": %w[TEST000000] },
          "configuration": {
            "load": {
              "endpoint": {
                "uri":
                  "http://test-endpoint/api/schemes/<%= scheme_id %>/assessors/<%= scheme_assessor_id %>",
                "method": "put",
              },
            },
            transform: {
              "rules": [
                {
                  "from": %w[data POSTCODE_COVERAGE * POSTCODE],
                  "to": %w[data postcodeCoverage],
                },
              ],
            },
          },
          "data": {
            "POSTCODE_COVERAGE": [
              { "POSTCODE": "SW1A 2AA" },
              { "POSTCODE": "SW2A 3AA" },
            ],
          },
        }.to_json,
      )
    end
  end

  class TransformRequestThreeStub
    def body
      JSON.parse(
        {
          "job": { "ASSESSOR": %w[TEST000000] },
          "configuration": {
            transform: {
              "rules": [
                {
                  "to": %w[data assessments],
                  "convert": [{ type: "populate", args: [[]] }],
                },
              ],
            },
          },
          "data": {},
        }.to_json,
      )
    end
  end

  class TransformRequestArrayTransformStub
    def body
      JSON.parse(
        {
          "job": { "ASSESSOR": %w[TEST000000] },
          "configuration": {
            "load": {
              "endpoint": {
                "uri":
                  "http://test-endpoint/api/schemes/<%= scheme_id %>/assessors/<%= scheme_assessor_id %>",
                "method": "put",
              },
            },
            transform: {
              "rules": [
                {
                  "from": ["data", "QUALIFICATIONS", "*", %w[TYPE STATUS]],
                  "to": ["data", "qualifications", "*", %w[type status]],
                },
              ],
            },
          },
          "data": {
            "QUALIFICATIONS": [
              { TYPE: "Level 1", STATUS: "ACTIVE" },
              { TYPE: "Level 2", STATUS: "INACTIVE" },
            ],
          },
        }.to_json,
      )
    end
  end

  context "when transforming data from extraction" do
    it "converts the first name to the body" do
      request = TransformRequestStub.new
      container = Container.new(false)
      message_gateway_fake = MessageGatewayFake.new
      container.set_object(:message_gateway, message_gateway_fake)
      transform = described_class.new(request, container)
      response = transform.execute

      expect(response).to eq(
        JSON.parse(
          {
            job: { ASSESSOR: %w[TEST000000] },
            "configuration": {
              "load": {
                "endpoint": {
                  "uri":
                    "http://test-endpoint/api/schemes/<%= scheme_id %>/assessors/<%= scheme_assessor_id %>",
                  "method": "put",
                },
              },
              "transform": {
                "rules": [
                  {
                    "from": %w[data ASSESSOR FIRST_NAME],
                    "to": %w[data firstName],
                  },
                ],
              },
            },
            "data": { "firstName": "Joe" },
          }.to_json,
        ),
      )
    end

    it "converts the postcode coverage array to the body" do
      request = TransformRequestTwoStub.new
      container = Container.new(false)
      message_gateway_fake = MessageGatewayFake.new
      container.set_object(:message_gateway, message_gateway_fake)
      transform = described_class.new(request, container)
      response = transform.execute

      expect(response).to eq(
        JSON.parse(
          {
            job: { ASSESSOR: %w[TEST000000] },
            "configuration": {
              "load": {
                "endpoint": {
                  "uri":
                    "http://test-endpoint/api/schemes/<%= scheme_id %>/assessors/<%= scheme_assessor_id %>",
                  "method": "put",
                },
              },
              "transform": {
                "rules": [
                  {
                    "from": %w[data POSTCODE_COVERAGE * POSTCODE],
                    "to": %w[data postcodeCoverage],
                  },
                ],
              },
            },
            "data": { "postcodeCoverage": ["SW1A 2AA", "SW2A 3AA"] },
          }.to_json,
        ),
      )
    end

    it "populates a property based on configuration" do
      request = TransformRequestThreeStub.new
      container = Container.new(false)
      message_gateway_fake = MessageGatewayFake.new
      container.set_object(:message_gateway, message_gateway_fake)
      transform = described_class.new(request, container)
      response = transform.execute

      expect(response).to eq(
        JSON.parse(
          {
            "job": { "ASSESSOR": %w[TEST000000] },
            "configuration": {
              transform: {
                "rules": [
                  {
                    "to": %w[data assessments],
                    "convert": [{ type: "populate", args: [[]] }],
                  },
                ],
              },
            },
            "data": { "assessments": [] },
          }.to_json,
        ),
      )
    end

    it "populates an array of objects" do
      request = TransformRequestArrayTransformStub.new
      container = Container.new(false)
      message_gateway_fake = MessageGatewayFake.new
      container.set_object(:message_gateway, message_gateway_fake)
      transform = described_class.new(request, container)
      response = transform.execute

      expect(response).to eq(
        JSON.parse(
          {
            "job": { "ASSESSOR": %w[TEST000000] },
            "configuration": {
              "load": {
                "endpoint": {
                  "uri":
                    "http://test-endpoint/api/schemes/<%= scheme_id %>/assessors/<%= scheme_assessor_id %>",
                  "method": "put",
                },
              },
              transform: {
                "rules": [
                  {
                    "from": ["data", "QUALIFICATIONS", "*", %w[TYPE STATUS]],
                    "to": ["data", "qualifications", "*", %w[type status]],
                  },
                ],
              },
            },
            "data": {
              "qualifications": [
                { type: "Level 1", status: "ACTIVE" },
                { type: "Level 2", status: "INACTIVE" },
              ],
            },
          }.to_json,
        ),
      )
    end
  end
end
