#
## TF file in answer to Q1
#
# please note the following assumptions
# - a VPC is already created with a subnet
# - the subnet has a route to an IG to allow external access
#
# Please note the following is not included as part of the answer
# - some of the EC2 setting including EBS volume and encryption/ssh key
# - the variables file
# - the outputs file
# - the userdata section of the EC2 instance
#

## create an instance with with external IP and dns record

provider "aws" {
  region = "eu-west-2"
}

resource "aws_instance" "houly_ec2" {
  ami           = "${var.ami_id}"
  instance_type = "t2.micro"
  subnet_id  = "${aws_subnet.houly_subnet.id}"
  iam_instance_profile = "${aws_iam_instance_profile.houly_profile.name}"

tags = {
  Name        = "houly-ec2-isntance"
  Environment = "Dev"
}

resource "aws_route53_record" "houly_dns" {
  zone_id = "${var.houly_zone_id}"
  name    = "www.houly.co.uk"
  type    = "A"
  ttl     = "300"
  records =  "${aws_instance.houly_ec2.private_ip}"
}

resource "aws_iam_role" "houly_s3_role" {
  name = "houly_s3_role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_iam_policy" "houly_s3_full" {
  name  = "houly-s3-policy"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "s3:*"
      ],
      "Effect": "Allow",
      "Action": [
        "s3:PutObject",
        "s3:GetObject",
        "s3:DeleteObject"
      ],
      "Resource": ["arn:aws:s3:::aws_s3_bucket.houly_s3/*"]
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "houly-attach" {
  role       = "${aws_iam_role.houly_s3_role.id}"
  policy_arn = "${aws_iam_policy.houly_s3_full.arn}"
}

resource "aws_iam_instance_profile" "houly_profile" {
  name = "houly_profile"
  role = "${aws_iam_role.houly_s3_role.name}"
}
