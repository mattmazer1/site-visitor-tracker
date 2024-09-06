resource "aws_iam_role" "ec2_role" {
  name = "ec2-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      },
    ]
  })
}

resource "aws_iam_policy" "ec2_policy" {
  name = "ec2_policy"
  path = "/"

  policy = jsonencode(
    {
      "Version" : "2012-10-17",
      "Statement" : [
        {
          "Action" : "ec2:*",
          "Effect" : "Allow",
          "Resource" : "*"
        },
        {
          "Effect" : "Allow",
          "Action" : "elasticloadbalancing:*",
          "Resource" : "*"
        },
        {
          "Effect" : "Allow",
          "Action" : "cloudwatch:*",
          "Resource" : "*"
        },
        {
          "Effect" : "Allow",
          "Action" : "autoscaling:*",
          "Resource" : "*"
        },
        {
          "Effect" : "Allow",
          "Action" : "iam:CreateServiceLinkedRole",
          "Resource" : "*",
          "Condition" : {
            "StringEquals" : {
              "iam:AWSServiceName" : [
                "autoscaling.amazonaws.com",
                "ec2scheduled.amazonaws.com",
                "elasticloadbalancing.amazonaws.com",
                "spot.amazonaws.com",
                "spotfleet.amazonaws.com",
                "transitgateway.amazonaws.com"
              ]
            }
          }
        },
        {
          "Effect" : "Allow",
          "Action" : [
            "rds:*",
            "application-autoscaling:DeleteScalingPolicy",
            "application-autoscaling:DeregisterScalableTarget",
            "application-autoscaling:DescribeScalableTargets",
            "application-autoscaling:DescribeScalingActivities",
            "application-autoscaling:DescribeScalingPolicies",
            "application-autoscaling:PutScalingPolicy",
            "application-autoscaling:RegisterScalableTarget",
            "cloudwatch:DescribeAlarms",
            "cloudwatch:GetMetricStatistics",
            "cloudwatch:PutMetricAlarm",
            "cloudwatch:DeleteAlarms",
            "cloudwatch:ListMetrics",
            "cloudwatch:GetMetricData",
            "ec2:DescribeAccountAttributes",
            "ec2:DescribeAvailabilityZones",
            "ec2:DescribeCoipPools",
            "ec2:DescribeInternetGateways",
            "ec2:DescribeLocalGatewayRouteTablePermissions",
            "ec2:DescribeLocalGatewayRouteTables",
            "ec2:DescribeLocalGatewayRouteTableVpcAssociations",
            "ec2:DescribeLocalGateways",
            "ec2:DescribeSecurityGroups",
            "ec2:DescribeSubnets",
            "ec2:DescribeVpcAttribute",
            "ec2:DescribeVpcs",
            "ec2:GetCoipPoolUsage",
            "sns:ListSubscriptions",
            "sns:ListTopics",
            "sns:Publish",
            "logs:DescribeLogStreams",
            "logs:GetLogEvents",
            "outposts:GetOutpostInstanceTypes",
            "devops-guru:GetResourceCollection"
          ],
          "Resource" : "*"
        },
        {
          "Effect" : "Allow",
          "Action" : "pi:*",
          "Resource" : [
            "arn:aws:pi:*:*:metrics/rds/*",
            "arn:aws:pi:*:*:perf-reports/rds/*"
          ]
        },
        {
          "Effect" : "Allow",
          "Action" : "iam:CreateServiceLinkedRole",
          "Resource" : "*",
          "Condition" : {
            "StringLike" : {
              "iam:AWSServiceName" : [
                "rds.amazonaws.com",
                "rds.application-autoscaling.amazonaws.com"
              ]
            }
          }
        },
        {
          "Action" : [
            "devops-guru:SearchInsights",
            "devops-guru:ListAnomaliesForInsight"
          ],
          "Effect" : "Allow",
          "Resource" : "*",
          "Condition" : {
            "ForAllValues:StringEquals" : {
              "devops-guru:ServiceNames" : [
                "RDS"
              ]
            },
            "Null" : {
              "devops-guru:ServiceNames" : "false"
            }
          }
        }
      ]
    }
  )
}

resource "aws_iam_instance_profile" "ec2_instance_profile" {
  name = "ec2-instance-profile"
  role = aws_iam_role.ec2_role.name
}

resource "aws_iam_role_policy_attachment" "ec2_role_policy_attachment" {
  role       = aws_iam_role.ec2_role.name
  policy_arn = aws_iam_policy.ec2_policy.arn
}

resource "aws_iam_role_policy_attachment" "ssm_policy_attachment" {
  role       = aws_iam_role.ec2_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

output "aws_iam_instance_profile_name" {
  value = aws_iam_instance_profile.ec2_instance_profile.name
}
