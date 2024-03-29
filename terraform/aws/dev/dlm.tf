# resource "aws_iam_role" "game_server_dlm" {
#   name = join(var.delimiter, [var.name, "dlm", var.stage, random_string.root.id])

#   assume_role_policy = <<EOF
# {
#     "Version": "2012-10-17",
#     "Statement": [
#         {
#             "Action": "sts:AssumeRole",
#             "Principal": {
#                 "Service": "dlm.amazonaws.com"
#             },
#             "Effect": "Allow"
#         }
#     ]
# }
# EOF

#   tags = merge(
#     var.tags,
#     { Name = join(var.delimiter, [var.name, "dlm", var.stage, random_string.root.id]) }
#   )
# }

# #tfsec:ignore:aws-iam-no-policy-wildcards
# resource "aws_iam_role_policy" "game_server_dlm" {
#   name = join(var.delimiter, [var.name, "dlm", var.stage, random_string.root.id])
#   role = aws_iam_role.game_server_dlm.id

#   policy = <<EOF
# {
#     "Version": "2012-10-17",
#     "Statement": [
#         {
#             "Effect": "Allow",
#             "Action": [
#                 "ec2:CreateSnapshot",
#                 "ec2:CreateSnapshots",
#                 "ec2:DeleteSnapshot",
#                 "ec2:DescribeInstances",
#                 "ec2:DescribeVolumes",
#                 "ec2:DescribeSnapshots"
#             ],
#             "Resource": "arn:aws:ec2:${var.region}:${var.aws_acct_id}::snapshot/*"
#         },
#         {
#             "Effect": "Allow",
#             "Action": [
#                 "ec2:CreateTags"
#             ],
#             "Resource": "arn:aws:ec2:${var.region}:${var.aws_acct_id}::snapshot/*"
#         },
#         {
#             "Effect": "Allow",
#             "Action": [
#                 "kms:Decrypt",
#                 "kms:Encrypt",
#                 "kms:GetPublicKey"
#             ],
#             "Resource": "arn:aws:kms:${var.region}:${var.aws_acct_id}:key/*"
#         }
#     ]
# }
# EOF
# }

# resource "aws_dlm_lifecycle_policy" "game_server_dlm" {
#   description        = join(var.delimiter, [var.name, "dlm", var.stage, random_string.root.id])
#   execution_role_arn = aws_iam_role.game_server_dlm.arn
#   state              = "ENABLED"

#   tags = merge(
#     var.tags,
#     { Name = join(var.delimiter, [var.name, "dlm", var.stage, random_string.root.id]) }
#   )

#   policy_details {
#     resource_types = ["VOLUME"]

#     schedule {
#       name = "2 weeks of daily snapshots"

#       create_rule {
#         interval      = 1
#         interval_unit = "HOURS"
#         times         = ["20:20"] # UTC
#       }

#       retain_rule {
#         count = 14
#       }

#       tags_to_add = {
#         SnapshotCreator = "DLM"
#       }

#       copy_tags = true
#     }

#     target_tags = {
#       Snapshot = "true"
#     }
#   }
# }