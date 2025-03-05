resource "aws_iam_role" "lambda_role" {
  name = "Spacelift_Test_Lambda_Function_Role"

  assume_role_policy = <<EOF
{
 "Version": "2012-10-17",
 "Statement": [
   {
     "Action": "sts:AssumeRole",
     "Principal": {
       "Service": "lambda.amazonaws.com"
     },
     "Effect": "Allow",
     "Sid": ""
   }
 ]
}
EOF
}

resource "aws_iam_policy" "iam_policy_for_lambda" { 
  name        = "aws_iam_policy_for_terraform_aws_lambda_role"
  path        = "/"
  description = "AWS IAM Policy for managing aws lambda role"

  policy = <<EOF
{
 "Version": "2012-10-17",
 "Statement": [
   {
     "Action": [
       "logs:CreateLogGroup",
       "logs:CreateLogStream",
       "logs:PutLogEvents",
       "ec2:DescribeNetworkInterfaces",
       "ec2:DescribeInstances",
       "ec2:DescribeSecurityGroups",
       "ec2:DescribeSubnets",
       "ec2:CreateNetworkInterface",
       "ec2:DeleteNetworkInterface",
       "rds-db:connect",
       "rds:DescribeDBInstances",
       "rds:DescribeDBClusters",
       "rds:DescribeDBLogFiles",
       "rds:DownloadDBLogFilePortion"
     ],
     "Resource": "*",
     "Effect": "Allow"
   }
 ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "attach_iam_policy_to_iam_role" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = aws_iam_policy.iam_policy_for_lambda.arn
}
