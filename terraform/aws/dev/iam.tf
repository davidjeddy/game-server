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
              "s3:Get*",
              "s3:List*"
            ],
            "Effect": "Allow",
            "Resource": [
                "${module.installers.s3_bucket_arn}",
                "${module.installers.s3_bucket_arn}/*"
            ]
        },
        {
            "Action": [
                "kms:Decrypt*",
                "kms:GenerateDateKey*"
            ],
            "Effect": "Allow",
            "Resource": [
                "${aws_kms_key.installers.arn}"
            ]
        },
        {
            "Action": [
                "kms:Decrypt*",
                "kms:GenerateDateKey*"
            ],
            "Effect": "Allow",
            "Resource": [
                "${aws_kms_key.pa_titans.arn}"
            ]
        },
        {
            "Action": [
                "secretsmanager:GetSecretValue"
            ],
            "Effect": "Allow",
            "Resource": [
                "${aws_secretsmanager_secret.pa_titans.arn}"
            ]
        }
    ]
}
EOF
}
