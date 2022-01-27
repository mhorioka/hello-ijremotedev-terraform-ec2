resource "aws_iam_role" "remotedev_cloudwatch_agent" {
  name               = "remotedev_cloudwatch_agent"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}

resource "aws_iam_role_policy_attachment" "remotedev_cloudwatch_agent" {
  role       = aws_iam_role.remotedev_cloudwatch_agent.name
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
}

resource "aws_iam_instance_profile" "remotedev_cloudwatch_agent_aim_profile" {
  name = "remotedev_cloudwatch_agent"
  role = aws_iam_role.remotedev_cloudwatch_agent.name
}

data "aws_iam_policy_document" "assume_role" {
  statement {
    sid = ""

    actions = [
      "sts:AssumeRole",
    ]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }

    effect = "Allow"
  }
}