#!/usr/bin/env node
import "source-map-support/register"
import * as cdk from "aws-cdk-lib"
import { Lab8Stack } from "../lib/lab8-stack"

const app = new cdk.App()
new Lab8Stack(app, "Lab8Stack", {
  env: {
    account: process.env.CDK_DEFAULT_ACCOUNT || "000000000000",
    region: process.env.CDK_DEFAULT_REGION || "us-east-1",
  },
})
