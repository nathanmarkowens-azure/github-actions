output "state-bucket" {
  description = "The name of the s3 state storage bucket."
  value       = aws_s3_bucket.this.id
}

output "state-lock-table" {
  description = "The name of the dynamodb table used for terraform state lock."
  value       = aws_dynamodb_table.this.name
}