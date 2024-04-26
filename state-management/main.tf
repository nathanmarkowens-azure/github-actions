data "aws_iam_policy_document" "kms" {
  version = "2012-10-17"

  statement {
    sid = "EnableIAMUserPermissions"

    effect = "Allow"

    actions = [
      "kms:*"
    ]

    resources = [
      "*"
    ]

    principals {
      type = "AWS"
      identifiers = [
        "arn:aws:iam::${local.account_id}:root"
      ]
    }
  }
}

resource "aws_kms_key" "this" {
  depends_on = [data.aws_iam_policy_document.kms]

  deletion_window_in_days = 30
  description             = "This customer managed key (cmk) is used to encrypt/decrypt objects in the ${local.name}-state-storage s3 bucket."
  key_usage               = "ENCRYPT_DECRYPT"
  multi_region            = false
  enable_key_rotation     = true
  policy                  = data.aws_iam_policy_document.kms.json

  tags = {
    Name     = "${local.name}-state-storage"
    Instance = "${local.instance}"
  }
}

resource "aws_kms_alias" "this" {
  name          = "alias/${local.name}-state-storage"
  target_key_id = aws_kms_key.this.key_id
}

resource "aws_s3_bucket" "this" {
  bucket = "${local.name}-state-storage-${local.instance}"

  tags = {
    Name     = "${local.name}-state-storage-${local.instance}"
    Instance = "${local.instance}"
  }
}

resource "aws_s3_bucket_public_access_block" "this" {
  bucket                  = aws_s3_bucket.this.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

data "aws_iam_policy_document" "bucket" {
  depends_on = [aws_kms_key.this]

  statement {
    sid = "DenyUnEncryptedObjectUploads"

    effect = "Deny"

    actions = [
      "s3:PutObject"
    ]

    resources = [
      "${aws_s3_bucket.this.arn}/*"
    ]

    principals {
      type = "*"
      identifiers = [
        "*"
      ]
    }

    condition {
      test     = "Null"
      variable = "s3:x-amz-server-side-encryption"
      values = [
        "true"
      ]
    }
  }

  statement {
    sid = "DenyInsecureTransport"

    effect = "Deny"

    actions = [
      "s3:*"
    ]

    resources = [
      "${aws_s3_bucket.this.arn}",
      "${aws_s3_bucket.this.arn}/*"
    ]

    principals {
      type = "*"
      identifiers = [
        "*"
      ]
    }

    condition {
      test     = "Bool"
      variable = "aws:SecureTransport"
      values = [
        "false"
      ]
    }
  }

  statement {
    sid = "DenyIncorrectEncryptionHeader"

    effect = "Deny"

    actions = [
      "s3:PutObject"
    ]

    resources = [
      "${aws_s3_bucket.this.arn}/*"
    ]

    principals {
      type = "*"
      identifiers = [
        "*"
      ]
    }

    condition {
      test     = "StringNotEquals"
      variable = "s3:x-amz-server-side-encryption"
      values = [
        "aws:kms"
      ]
    }

    condition {
      test     = "StringNotEquals"
      variable = "s3:x-amz-server-side-encryption-aws-kms-key-id"
      values = [
        "${aws_kms_key.this.arn}"
      ]
    }
  }
}

resource "aws_s3_bucket_policy" "this" {
  bucket = aws_s3_bucket.this.id
  policy = data.aws_iam_policy_document.bucket.json
}

resource "aws_s3_bucket_ownership_controls" "this" {
  bucket = aws_s3_bucket.this.id

  rule {
    object_ownership = "BucketOwnerEnforced"
  }

  depends_on = [
    # The following defined resources are here to prevent a potential condition
    # where Terraform thinks that operations are currently pending on the resource.
    data.aws_iam_policy_document.bucket,
    aws_s3_bucket_public_access_block.this,
    aws_s3_bucket.this
  ]
}

resource "aws_s3_bucket_versioning" "this" {
  bucket = aws_s3_bucket.this.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "this" {
  bucket = aws_s3_bucket.this.id

  rule {
    apply_server_side_encryption_by_default {
      kms_master_key_id = aws_kms_key.this.arn
      sse_algorithm     = "aws:kms"
    }

    bucket_key_enabled = true
  }
}

resource "aws_dynamodb_table" "this" {
  name         = "${local.name}-state-lock"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }

  server_side_encryption {
    enabled = true
  }

  tags = {
    Name     = "${local.name}-state-lock"
    Instance = "${local.instance}"
  }
}
