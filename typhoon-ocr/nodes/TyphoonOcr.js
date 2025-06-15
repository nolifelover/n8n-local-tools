const { IExecuteFunctions } = require("n8n-core");
const { NodeOperationError } = require("n8n-workflow");
const axios = require("axios");

module.exports = {
  name: "typhoonOcr",
  displayName: "Typhoon OCR",
  description: "Process documents using Typhoon OCR",
  version: 1,
  defaults: {
    name: "Typhoon OCR",
  },
  inputs: ["main"],
  outputs: ["main"],
  credentials: [
    {
      name: "typhoonOcrApi",
      required: true,
    },
  ],
  properties: [
    {
      displayName: "Operation",
      name: "operation",
      type: "options",
      noDataExpression: true,
      options: [
        {
          name: "Process Document",
          value: "processDocument",
          description: "Process a document using OCR",
        },
      ],
      default: "processDocument",
    },
    {
      displayName: "File",
      name: "file",
      type: "string",
      required: true,
      displayOptions: {
        show: {
          operation: ["processDocument"],
        },
      },
      description: "URL or base64 of the file to process",
    },
    {
      displayName: "Task Type",
      name: "taskType",
      type: "options",
      required: true,
      displayOptions: {
        show: {
          operation: ["processDocument"],
        },
      },
      options: [
        {
          name: "Default",
          value: "default",
        },
        {
          name: "Structure",
          value: "structure",
        },
      ],
      default: "default",
      description: "Type of OCR processing to perform",
    },
  ],
  async execute() {
    const items = this.getInputData();
    const returnData = [];
    const operation = this.getNodeParameter("operation", 0);

    for (let i = 0; i < items.length; i++) {
      try {
        if (operation === "processDocument") {
          const file = this.getNodeParameter("file", i);
          const taskType = this.getNodeParameter("taskType", i);

          const response = await axios.post(
            `${process.env.TYPHOON_OCR_URL}/process`,
            {
              file,
              task_type: taskType,
            },
            {
              headers: {
                Authorization: `Bearer ${process.env.TYPHOON_OCR_API_KEY}`,
                "Content-Type": "application/json",
              },
            }
          );

          returnData.push({
            json: response.data,
          });
        }
      } catch (error) {
        if (this.continueOnFail()) {
          returnData.push({
            json: {
              error: error.message,
            },
          });
          continue;
        }
        throw new NodeOperationError(this.getNode(), error);
      }
    }

    return [returnData];
  },
};
