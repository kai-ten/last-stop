resource "null_resource" "gobuild" {
  triggers = {
    dependencies_versions = random_uuid.lambda_src_hash.result
  }

  provisioner "local-exec" {
    command = "cd ${var.src_path} && rm -rf ./dist/*.zip && CGO_ENABLED=0 GOARCH=amd64 GOOS=linux go build -o ./dist && zip -r ./dist/${random_uuid.lambda_src_hash.result}.zip ./dist/main"
  }
}

resource "random_uuid" "lambda_src_hash" {
  keepers = {
    for filename in setunion(
      fileset(var.src_path, "**/*.go"),
      fileset(var.src_path, "go.*"),
    ) :
    filename => join("-", concat([var.name], [filemd5("${var.src_path}/${filename}")]))
  }
}
