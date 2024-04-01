output "state-bucket-name" {
  description = "The name of the s3 state storage bucket."
  value       = aws_s3_bucket.this.id
}

output "state-lock-table-name" {
  description = "The name of the dynamodb table used for terraform state lock."
  value       = aws_dynamodb_table.this.name
}

output "kms_key_arn" {
  description = "The AWS arn of the kms key used for terraform state lock."
  value       = aws_kms_key.this.arn
}