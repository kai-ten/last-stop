resource "aws_dynamodb_table" "last_stop_audit_log" {
  name           = "LastStopAuditLog"
  billing_mode   = "PAY_PER_REQUEST"
  hash_key       = "id"

  attribute {
    name = "id"
    type = "S"
  }

  attribute {
    name = "participant"
    type = "S"
  }

  attribute {
    name = "timestamp"
    type = "N"
  }

  global_secondary_index {
    name               = "participant-timestamp-index"
    hash_key           = "participant"
    range_key          = "timestamp"
    projection_type    = "ALL"
  }

  tags = {
    Project = "Last Stop"
  }
}