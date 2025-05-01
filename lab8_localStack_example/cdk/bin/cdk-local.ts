#!/usr/bin/env node
import "source-map-support/register"
import * as cdk from "aws-cdk-lib"
import { Lab8Stack } from "../lib/lab8-stack"

const app = new cdk.App()

// Check if we're using LocalStack
const useLocalStack = app.node.tryGetContext("use_localstack") === "true"

// Create the stack with environment configuration
new Lab8Stack(app, "Lab8Stack", {
  env: {
    account: "000000000000", // Dummy account ID for LocalStack
    region: process.env.AWS_DEFAULT_REGION || "us-east-1",
  },
  // Pass useLocalStack as a custom property
  description: `Lab8 infrastructure${useLocalStack ? " (LocalStack)" : ""}`,
})

// Set context at the app level
app.node.setContext("useLocalStack", useLocalStack)
