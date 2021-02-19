resource "aws_s3_bucket" "b" {
  bucket = "${path.module}-foo"
}
