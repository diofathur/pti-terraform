resource "aws_iam_instance_profile" "role-profile" {
  name = "ec2_profile"
  role = aws_iam_role.role.name
}

resource "aws_iam_role" "role" {
  name        = "ec2-role"
  description = "role for ssm cw ec2"
  assume_role_policy = jsonencode(
    {
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
    }
  )

  tags = {
    stack = "test"
  }
}

resource "aws_iam_role_policy_attachment" "ssm-policy" {
  role       = aws_iam_role.role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_role_policy_attachment" "cwfull" {
  role       = aws_iam_role.role.name
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchFullAccess"
}

resource "aws_iam_role_policy_attachment" "cwagentfull" {
  role       = aws_iam_role.role.name
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
}

resource "aws_iam_role_policy_attachment" "ec2" {
  role       = aws_iam_role.role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2FullAccess"
}

resource "aws_iam_user" "veeam" {
  name = "s3-veaam" // don't forget to change this name 
}


data "aws_iam_policy_document" "veeam_ro" {
  statement {
    effect    = "Allow"
    actions   = ["s3:PutObject","s3:GetObject","s3:DeleteObject","s3:GetBucketLocation","s3:GetBucketVersioning","s3:GetBucketObjectLockConfiguration","s3:ListAllMyBuckets","s3:ListBucket","ec2:*"]
    resources = ["*"]
  }
}

resource "aws_iam_user_policy" "veeam-policy" {
  name   = "veeam-policy" // don't forget to change this name 
  user   = aws_iam_user.veeam.name
  policy = data.aws_iam_policy_document.veeam_ro.json
}
