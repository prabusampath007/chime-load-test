resource "aws_security_group" "sipp-server-sg" {
  vpc_id = var.vpc_id
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = -1
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "SIP traffic from outside world"
    from_port   = 5060
    to_port     = 5060
    protocol    = "udp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "SIP traffic from outside world"
    from_port   = 5060
    to_port     = 5060
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

data "aws_ami" "ubuntu" {
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-20220912"]
  }
}

resource "aws_s3_bucket" "load_test_asset" {
  bucket        = "${var.service_name}-sipp-server-asset"
  force_destroy = true
}

resource "aws_s3_bucket_policy" "allow_access_with_in_account" {
  bucket = aws_s3_bucket.load_test_asset.id
  policy = data.aws_iam_policy_document.allow_access_with_in_account.json
}

data "aws_iam_policy_document" "allow_access_with_in_account" {
  statement {
    principals {
      type        = "AWS"
      identifiers = [var.aws_account_id]
    }

    actions = [
      "s3:GetObject",
      "s3:ListBucket",
    ]

    resources = [
      aws_s3_bucket.load_test_asset.arn,
      "${aws_s3_bucket.load_test_asset.arn}/*",
    ]
  }
}

resource "aws_s3_object" "scenario_resource_asset" {
  for_each = fileset("../assets/", "**")

  bucket = aws_s3_bucket.load_test_asset.id
  key    = each.value
  source = "../assets/${each.value}"
  etag   = md5("../assets/${each.value}")
}

resource "aws_iam_policy" "s3_bucket_access" {
  name        = "${var.service_name}-s3-access-policy"
  path        = "/"
  description = "Allows read to the assets s3 bucket"
  policy      = data.aws_iam_policy_document.s3_bucket_read.json
}

data "aws_iam_policy_document" "s3_bucket_read" {
  statement {
    sid = "1"
    actions = [
      "s3:ListBucket",
      "s3:GetObject"
    ]
    resources = [
      "${aws_s3_bucket.load_test_asset.arn}/*"
    ]
  }
}

resource "aws_iam_role_policy_attachment" "s3_bucket_read" {
  role       = aws_iam_role.sipp_server_role.name
  policy_arn = aws_iam_policy.s3_bucket_access.arn
}

data "aws_iam_policy" "ssm_instance_core" {
  arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_role_policy_attachment" "ssm_core_ec2" {
  role       = aws_iam_role.sipp_server_role.name
  policy_arn = data.aws_iam_policy.ssm_instance_core.arn
}

resource "aws_iam_instance_profile" "sipp_server_profile" {
  name = "${var.service_name}-sipp-server-profile"
  role = aws_iam_role.sipp_server_role.name
  path = "/"
}

resource "aws_iam_role" "sipp_server_role" {
  name = "${var.service_name}-sipp-server-role"
  path = "/"

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

resource "aws_key_pair" "sipp_server_key_pair" {
  key_name   = "${var.service_name}-key-pair"
  public_key = tls_private_key.sipp_server_private_key.public_key_openssh
}

resource "tls_private_key" "sipp_server_private_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

data "template_file" "init_script" {
  template = file("sipp_setup.sh.tpl")
  vars = {
    ASSET_BUCKET       = aws_s3_bucket.load_test_asset.id,
    REQUIRED_RESOURCES = join(", ", setunion(values(aws_s3_object.scenario_resource_asset)[*].etag))
  }
}

resource "aws_instance" "sipp_server" {
  ami                         = data.aws_ami.ubuntu.id
  instance_type               = var.instance_type
  vpc_security_group_ids      = [aws_security_group.sipp-server-sg.id]
  key_name                    = aws_key_pair.sipp_server_key_pair.key_name
  user_data                   = data.template_file.init_script.rendered
  subnet_id                   = var.public_subnet_id
  associate_public_ip_address = true
  user_data_replace_on_change = true
  iam_instance_profile        = aws_iam_instance_profile.sipp_server_profile.name
  tags = {
    Name = "${var.service_name}-sipp-server"
  }
}
