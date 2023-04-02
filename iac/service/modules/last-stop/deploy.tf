# Build npm then run s3 sync command aws s3 sync build/ s3://your-bucket-name ? whats acl for private
# Replace with pipeline eventually 

# Pass in env file name here

resource "null_resource" "npm_build" {
#   triggers = {
#     dependencies_versions = random_uuid.lambda_src_hash.result
#   }
  triggers = {
    always_run = "${timestamp()}"
  }

  provisioner "local-exec" {
    command = <<EOT
cd ../../lib/last-stop
rm -r ./build
echo "REACT_APP_API_ENDPOINT=${aws_api_gateway_deployment.last_stop_deployment.invoke_url}v1/stepfunction" > .env.${terraform.workspace}
cat .env.${terraform.workspace}
npm run env-cmd .env.${terraform.workspace} npm run build
aws s3 sync build/ s3://${aws_s3_bucket.last_stop_website_bucket.id} --delete
aws cloudfront create-invalidation --distribution-id ${aws_cloudfront_distribution.last_stop_distribution.id} --paths "/*"
    EOT
  }
}
