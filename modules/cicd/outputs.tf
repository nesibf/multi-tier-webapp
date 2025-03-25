output "iam_role_arn" {
  value = aws_iam_role.github_actions_role.arn
}

output "frontend_s3_bucket" {
  value = aws_s3_bucket.frontend.bucket
}