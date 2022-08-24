# -----
# IAM for EC2 game-server
# - read PA credentials
# -----

resource "aws_iam_role" "game_server" {
  name = join(var.delimiter, [var.name, var.stage, random_string.root.id])

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Effect": "Allow",
      "Principal": {"Service": "ec2.amazonaws.com"}
    }
  ]
}
EOF

  tags = merge(
    var.tags,
    {
      Name = join(var.delimiter, [var.name, var.stage, random_string.root.id])
    }
  )
}

resource "aws_iam_instance_profile" "game_server" {
  name = "game_server"
  role = aws_iam_role.game_server.name

  tags = merge(
    var.tags,
    {
      Name = join(var.delimiter, [var.name, var.stage, random_string.root.id])
    }
  )
}

resource "aws_iam_role_policy" "game_server" {
  name = "game_server"
  role = aws_iam_role.game_server.id

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "kms:Decrypt",
        "kms:Encrypt",
        "kms:GetPublicKey"
      ],
      "Effect": "Allow",
      "Resource": [
        "arn:aws:kms:us-east-1:530589290119:key/8ec2a9ed-6dc6-41a9-baa6-f47b11d63890"
      ]
    },
    {
      "Action": [
        "secretsmanager:GetSecretValue"
      ],
      "Effect": "Allow",
      "Resource": [
        "arn:aws:secretsmanager:us-east-1:530589290119:secret:gs/pa_titans-uops-0-ux4b-WYzVAB"
      ]
    }
  ]
}
EOF
}
