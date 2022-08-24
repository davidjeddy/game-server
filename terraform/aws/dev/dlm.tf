resource "aws_iam_role" "game_server_dlm" {
  name = join(var.delimiter, [var.name, "dlm", var.stage, random_string.root.id])

  assume_role_policy = file("./iam_policies/role_policy_dlm.json.json")

  tags = merge(
    var.tags,
    { Name = join(var.delimiter, [var.name, "dlm", var.stage, random_string.root.id]) }
  )
}

#tfsec:ignore:aws-iam-no-policy-wildcards
resource "aws_iam_role_policy" "game_server_dlm" {
  name = join(var.delimiter, [var.name, "dlm", var.stage, random_string.root.id])
  role = aws_iam_role.game_server_dlm.id

  policy = file("./iam_policies/role_policy_dlm.json")
}

resource "aws_dlm_lifecycle_policy" "game_server_dlm" {
  description        = join(var.delimiter, [var.name, "dlm", var.stage, random_string.root.id])
  execution_role_arn = aws_iam_role.game_server_dlm.arn
  state              = "ENABLED"

  tags = merge(
    var.tags,
    { Name = join(var.delimiter, [var.name, "dlm", var.stage, random_string.root.id]) }
  )

  policy_details {
    resource_types = ["VOLUME"]

    schedule {
      name = "2 weeks of daily snapshots"

      create_rule {
        interval      = 24
        interval_unit = "HOURS"
        times         = ["23:45"]
      }

      retain_rule {
        count = 14
      }

      tags_to_add = {
        SnapshotCreator = "DLM"
      }

      copy_tags = false
    }

    target_tags = {
      Snapshot = "true"
    }
  }
}