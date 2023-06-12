# Create Lambda layer
resource "aws_lambda_layer_version" "rbac_handler_layer" {
  layer_name = "${var.layer_name}-${var.stage}"  
  s3_bucket  = aws_s3_bucket.rbac_handler_buckets["bucket_2"].bucket
  s3_key     = "provisioning-lambda-layer"  
  compatible_runtimes = ["python3.9"] 
}

#create an empty file for the object
resource "null_resource" "lambda_layer_object" {
  provisioner "local-exec" {
    command = "touch empty.txt"
  }

  triggers = {
    timestamp = timestamp()
  }
}
#creating s3_key
resource "aws_s3_bucket_object" "lambda_layer_object" {
  bucket = aws_s3_bucket.rbac_handler_buckets["bucket_2"].bucket
  key    = "provisioning-lambda-layer"
  #source = null_resource.lambda_layer_object.id
}
