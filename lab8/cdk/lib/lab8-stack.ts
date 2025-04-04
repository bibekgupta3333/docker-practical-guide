import * as cdk from "aws-cdk-lib"
import { Construct } from "constructs"
import * as ec2 from "aws-cdk-lib/aws-ec2"
import * as ecs from "aws-cdk-lib/aws-ecs"
import * as ecr from "aws-cdk-lib/aws-ecr"
import * as elbv2 from "aws-cdk-lib/aws-elasticloadbalancingv2"
import * as iam from "aws-cdk-lib/aws-iam"
import * as logs from "aws-cdk-lib/aws-logs"
import * as path from "path"

export class Lab8Stack extends cdk.Stack {
  constructor(scope: Construct, id: string, props?: cdk.StackProps) {
    super(scope, id, props)

    // Check if we're using LocalStack
    const useLocalStack = this.node.tryGetContext("use_localstack") === true

    // Configure environment for LocalStack if needed
    if (useLocalStack) {
      console.log("Deploying to LocalStack environment")
    } else {
      console.log("Deploying to AWS environment")
    }

    // Create a VPC
    const vpc = new ec2.Vpc(this, "Lab8Vpc", {
      maxAzs: 2,
      natGateways: 1,
    })

    // Create an ECS Cluster
    const cluster = new ecs.Cluster(this, "Lab8Cluster", {
      vpc,
      containerInsights: true,
    })

    // Create or reference ECR Repositories for our images
    let backendRepo, frontendRepo, nginxRepo

    if (useLocalStack) {
      // For LocalStack, we'll reference existing repositories or use hardcoded values
      // since ECR in LocalStack community edition is limited
      console.log("Using mock ECR repositories for LocalStack")

      backendRepo = {
        repositoryUri: "localhost:4566/lab8-backend",
        repositoryName: "lab8-backend",
      } as any

      frontendRepo = {
        repositoryUri: "localhost:4566/lab8-frontend",
        repositoryName: "lab8-frontend",
      } as any

      nginxRepo = {
        repositoryUri: "localhost:4566/lab8-nginx",
        repositoryName: "lab8-nginx",
      } as any
    } else {
      // For AWS, create new repositories
      backendRepo = new ecr.Repository(this, "BackendRepo", {
        repositoryName: "lab8-backend",
        removalPolicy: cdk.RemovalPolicy.DESTROY,
      })

      frontendRepo = new ecr.Repository(this, "FrontendRepo", {
        repositoryName: "lab8-frontend",
        removalPolicy: cdk.RemovalPolicy.DESTROY,
      })

      nginxRepo = new ecr.Repository(this, "NginxRepo", {
        repositoryName: "lab8-nginx",
        removalPolicy: cdk.RemovalPolicy.DESTROY,
      })
    }

    // Create a Task Execution Role
    const executionRole = new iam.Role(this, "Lab8TaskExecutionRole", {
      assumedBy: new iam.ServicePrincipal("ecs-tasks.amazonaws.com"),
      managedPolicies: [
        iam.ManagedPolicy.fromAwsManagedPolicyName(
          "service-role/AmazonECSTaskExecutionRolePolicy"
        ),
      ],
    })

    // Create a Task Role
    const taskRole = new iam.Role(this, "Lab8TaskRole", {
      assumedBy: new iam.ServicePrincipal("ecs-tasks.amazonaws.com"),
    })

    // Create Log Groups
    const backendLogGroup = new logs.LogGroup(this, "BackendLogGroup", {
      logGroupName: "/ecs/lab8-backend",
      removalPolicy: cdk.RemovalPolicy.DESTROY,
      retention: logs.RetentionDays.ONE_WEEK,
    })

    const frontendLogGroup = new logs.LogGroup(this, "FrontendLogGroup", {
      logGroupName: "/ecs/lab8-frontend",
      removalPolicy: cdk.RemovalPolicy.DESTROY,
      retention: logs.RetentionDays.ONE_WEEK,
    })

    const nginxLogGroup = new logs.LogGroup(this, "NginxLogGroup", {
      logGroupName: "/ecs/lab8-nginx",
      removalPolicy: cdk.RemovalPolicy.DESTROY,
      retention: logs.RetentionDays.ONE_WEEK,
    })

    const rabbitmqLogGroup = new logs.LogGroup(this, "RabbitmqLogGroup", {
      logGroupName: "/ecs/lab8-rabbitmq",
      removalPolicy: cdk.RemovalPolicy.DESTROY,
      retention: logs.RetentionDays.ONE_WEEK,
    })

    // Create a Task Definition for our application
    const taskDefinition = new ecs.FargateTaskDefinition(this, "Lab8TaskDef", {
      memoryLimitMiB: 2048,
      cpu: 1024,
      executionRole,
      taskRole,
    })

    // Add container definitions
    // For LocalStack, we use hardcoded image values to avoid ECR issues
    // For AWS, we use the ECR repositories

    const backendContainer = taskDefinition.addContainer("backend", {
      image: useLocalStack
        ? ecs.ContainerImage.fromRegistry("localhost:4566/lab8-backend:latest")
        : ecs.ContainerImage.fromEcrRepository(backendRepo as ecr.IRepository),
      logging: ecs.LogDrivers.awsLogs({
        streamPrefix: "backend",
        logGroup: backendLogGroup,
      }),
      environment: {
        NODE_ENV: "production",
        PORT: "3000",
        RABBITMQ_URL: "amqp://rabbitmq:5672",
      },
      essential: true,
    })

    backendContainer.addPortMappings({
      containerPort: 3000,
    })

    const frontendContainer = taskDefinition.addContainer("frontend", {
      image: useLocalStack
        ? ecs.ContainerImage.fromRegistry("localhost:4566/lab8-frontend:latest")
        : ecs.ContainerImage.fromEcrRepository(frontendRepo as ecr.IRepository),
      logging: ecs.LogDrivers.awsLogs({
        streamPrefix: "frontend",
        logGroup: frontendLogGroup,
      }),
      essential: true,
    })

    frontendContainer.addPortMappings({
      containerPort: 80,
    })

    const rabbitmqContainer = taskDefinition.addContainer("rabbitmq", {
      image: ecs.ContainerImage.fromRegistry("rabbitmq:3-management"),
      logging: ecs.LogDrivers.awsLogs({
        streamPrefix: "rabbitmq",
        logGroup: rabbitmqLogGroup,
      }),
      environment: {
        RABBITMQ_DEFAULT_USER: "guest",
        RABBITMQ_DEFAULT_PASS: "guest",
      },
      essential: true,
    })

    rabbitmqContainer.addPortMappings(
      {
        containerPort: 5672, // AMQP protocol
      },
      {
        containerPort: 15672, // Management UI
      }
    )

    const nginxContainer = taskDefinition.addContainer("nginx", {
      image: useLocalStack
        ? ecs.ContainerImage.fromRegistry("localhost:4566/lab8-nginx:latest")
        : ecs.ContainerImage.fromEcrRepository(nginxRepo as ecr.IRepository),
      logging: ecs.LogDrivers.awsLogs({
        streamPrefix: "nginx",
        logGroup: nginxLogGroup,
      }),
      essential: true,
    })

    nginxContainer.addPortMappings({
      containerPort: 80,
    })

    // Create a security group for the load balancer
    const lbSecurityGroup = new ec2.SecurityGroup(this, "LBSecurityGroup", {
      vpc,
      description: "Security group for the load balancer",
      allowAllOutbound: true,
    })

    lbSecurityGroup.addIngressRule(
      ec2.Peer.anyIpv4(),
      ec2.Port.tcp(80),
      "Allow HTTP traffic"
    )

    // Create a security group for the ECS service
    const serviceSecurityGroup = new ec2.SecurityGroup(
      this,
      "ServiceSecurityGroup",
      {
        vpc,
        description: "Security group for the ECS service",
        allowAllOutbound: true,
      }
    )

    serviceSecurityGroup.addIngressRule(
      lbSecurityGroup,
      ec2.Port.tcp(80),
      "Allow traffic from the load balancer"
    )

    // Create an Application Load Balancer
    const lb = new elbv2.ApplicationLoadBalancer(this, "Lab8ALB", {
      vpc,
      internetFacing: true,
      securityGroup: lbSecurityGroup,
    })

    // Create a target group for the service
    const targetGroup = new elbv2.ApplicationTargetGroup(
      this,
      "Lab8TargetGroup",
      {
        vpc,
        port: 80,
        protocol: elbv2.ApplicationProtocol.HTTP,
        targetType: elbv2.TargetType.IP,
        healthCheck: {
          path: "/",
          interval: cdk.Duration.seconds(60),
          timeout: cdk.Duration.seconds(5),
          healthyHttpCodes: "200-299",
        },
      }
    )

    // Add a listener to the load balancer
    const listener = lb.addListener("Listener", {
      port: 80,
      defaultTargetGroups: [targetGroup],
    })

    // Create an ECS Service
    const service = new ecs.FargateService(this, "Lab8Service", {
      cluster,
      taskDefinition,
      desiredCount: 1,
      securityGroups: [serviceSecurityGroup],
      assignPublicIp: false,
    })

    // Attach the service to the target group
    service.attachToApplicationTargetGroup(targetGroup)

    // Output the load balancer DNS name
    new cdk.CfnOutput(this, "LoadBalancerDNS", {
      value: lb.loadBalancerDnsName,
      description: "The DNS name of the load balancer",
    })

    // Output the ECR repository URLs
    if (useLocalStack) {
      // For LocalStack, output the mock repository URIs
      new cdk.CfnOutput(this, "BackendRepositoryURI", {
        value: "localhost:4566/lab8-backend",
        description: "The URI of the backend mock repository",
      })

      new cdk.CfnOutput(this, "FrontendRepositoryURI", {
        value: "localhost:4566/lab8-frontend",
        description: "The URI of the frontend mock repository",
      })

      new cdk.CfnOutput(this, "NginxRepositoryURI", {
        value: "localhost:4566/lab8-nginx",
        description: "The URI of the nginx mock repository",
      })
    } else {
      // For AWS, output the real repository URIs
      new cdk.CfnOutput(this, "BackendRepositoryURI", {
        value: (backendRepo as ecr.Repository).repositoryUri,
        description: "The URI of the backend ECR repository",
      })

      new cdk.CfnOutput(this, "FrontendRepositoryURI", {
        value: (frontendRepo as ecr.Repository).repositoryUri,
        description: "The URI of the frontend ECR repository",
      })

      new cdk.CfnOutput(this, "NginxRepositoryURI", {
        value: (nginxRepo as ecr.Repository).repositoryUri,
        description: "The URI of the nginx ECR repository",
      })
    }
  }
}
