provider aws {
  region = "ap-south-1"
  profile = "derek"
}

##creating the security groups##
resource "aws_security_group" "security_group1" {
  name        = "allow_tcp"
  description = "Allow TCP and SSH inbound traffic"
  vpc_id      = "vpc-"

 ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

 ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

 ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "sg1"
  }
}

##creating the security group2 for nfs server##
resource "aws_security_group" "security_group2" {
  name        = "allow_nfs"
  description = "Allow TCP and NFS inbound traffic"
  vpc_id      = "vpc-"

 ingress {
    from_port   = 2049
    to_port     = 2049
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "sg2"
  }
}
output "op_security_group" {
  value = aws_security_group.security_group2
}

/*
##Creating a valid key-pair##
//CREATING A KEY//
resource "tls_private_key" "key_algo" {
   algorithm = "RSA"
   rsa_bits = 4096
}
output "opkey" {
  value = "tls_private_key.key_algo" 
}

//SAVING TO DRIVE//
resource "local_file" "key_store" {
   content = tls_private_key.key_algo.private_key_pem
   filename = "C://Users/Akshat/Desktop/terakey1.pem"
   file_permission = "0400"
}

resource "aws_key_pair" "productn_key" {
   key_name = "terakey1"
   public_key = tls_private_key.key_algo.public_key_openssh
}
resource "aws_key_pair" "productn_key" {
  key_name = "terakey1"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAABJQAAAgEAh5YEN8bECdP7zZZ0DSsOuuSfBUpW1szl9+4LabaLmqzWr3ZuZQbIPEZYkw4GtmaC34LD0kp+Nyald9giZ8Fib63u4H+fOIzioReMOmGd8xxAqHkCuFRoEiQWV2tudM2fGwxBGXgYy9k55jhvYSI4472FwUkmTNjLaFfiGWlMji87nvzTSVjlaf4udg9BEtO2QZdr8/8d1xfHyHRlNh9+9wFO0e9mwk9b+rVDnwmEm5AWk6ok+uvQmWixtMYpZ8j/lxqxZtgmGh12gwLScqNnfTRNlQX949eiebPShNndEfqCzFFvFOuLyL7e/h2zv2IDbUSoNO7NJN84rmJoyI/0eN6cBBdKnsDV8XLI2HzxyCnMDoDj2wggocaD7Dd7kOBvQJba0nIWkRJbPrr2Z0C/0svSxaXMgPBClbPOaPKIuzU5PAIF8ESkYVbCppM2OwXnwoLFgjUFzMeI96d+uOrERTs932ClyjXTgWmimoeCY8iCQwex90GKThyHYbZap+ngqiAi4zctiuSD+k/H2RYc9JN4I+8d0viFfCn3gEBrGfPqBoCoTOK+ajqgIW6UBcUdny/Du44Y0ZbWfOaJ3tmMl4JW71TU13CE7S2Y4QP92++HLskkXBFuGsOP/UndUuVlGIpQnYKVJUYrgT/QXdZH005aQZXMHtAjQkkshL"
}

##Getting the output for the key created##
output "opkey" {
  value = aws_key_pair.productn_key 
}
*/

##setting variable for the key##
variable "insert_key_var" {
     type = string
//   default = "terask"
}

##creating file system##
resource "aws_efs_file_system" "efs" {
  creation_token = "EFSbound"
  performance_mode = "generalPurpose"
  tags = {
      Name = "EFSbound"
  } 
}
output "op_efs_file" {
  value = aws_efs_file_system.efs
}

##Providing the mount target to the efs##
resource "aws_efs_mount_target" "alpha" {
  depends_on = [
      aws_efs_file_system.efs
  ]
  file_system_id = aws_efs_file_system.efs.id
  security_groups = ["${aws_security_group.security_group2.id}"]
  subnet_id = "subnet-"  //you can create a variable and then pass the values of different subnet from it
}
resource "aws_efs_mount_target" "alphas" {
  depends_on = [
      aws_efs_file_system.efs
  ]
  file_system_id = aws_efs_file_system.efs.id
  security_groups = ["${aws_security_group.security_group2.id}"]
  subnet_id = "subnet-"
}
resource "aws_efs_mount_target" "alphat" {
  depends_on = [
      aws_efs_file_system.efs
  ]
  file_system_id = aws_efs_file_system.efs.id
  security_groups = ["${aws_security_group.security_group2.id}"]
  subnet_id = "subnet-"
}

##LAUNCHING AN INSTANCE##
resource "aws_instance" "inst1" {
    depends_on = [
      aws_efs_mount_target.alpha
  ]
  ami = "ami-08706cb5f68222d09"
  instance_type = "t2.micro"
  key_name = var.insert_key_var
  security_groups = [ "allow_tcp" ]
  tags = {
    Name = "server1"
    Terraform = "true"
  }
  volume_tags = {
    Name = "test_efs"
    Terraform = "true"
  }
}

##outputs of the instances##
output "op_inst_ip" {
  value = aws_instance.inst1.public_ip
}

output "op_inst" {
  value = aws_instance.inst1
}

/*
//getting the output in a text document//
resource "null_resource" "doc_instance" {
  provisioner  "local-exec" {
            command = "echo ${aws_instance.inst1.public_ip} > instance_details.txt"
			
  }
}
*/

resource "null_resource" "connecting_ip" {
      depends_on = [
             aws_instance.inst1
      ]
	  connection  {
          type = "ssh"
          user = "ec2-user"
          private_key = file("C:/Users/Akshat/Desktop/ukey1.pem")
          host = aws_instance.inst1.public_ip
      }
      
      provisioner  "remote-exec" {
          inline = [
              "sudo yum install httpd php git -y",
              "sudo systemctl restart httpd",
              "sudo systemctl enable httpd",
              "sudo yum install -y amazon-efs-utils",
              "sudo mount -t nfs4 -o nfsvers=4.1,rsize=1048576,wsize=1048576,hard,timeo=600,retrans=2,noresvport ${aws_efs_file_system.efs.dns_name}:/ /var/www/html/",
              "sudo su -c \"echo '${aws_efs_file_system.efs.dns_name}:/ /var/www/html nfs4 defaults,vers=4.1,rsize=1048576,wsize=1048576,hard,timeo=600,retrans=2,noresvport 0 0' >> /etc/fstab\"", 
              "sudo git clone https://github.com/akshat-crypto/HCC_Task1.git  /var/www/html",
          ]
      }
}



####CREATING THE BUCKET FOR THE ABOVE INSTANCE TO STORE THE DATA####

resource "aws_s3_bucket" "bucket" {
  
  depends_on = [
          null_resource.connecting_ip
    ]
  bucket = "task1-bucket8526"
  acl    = "public-read"
  region = "ap-south-1"
  tags = {
    Name        = "Mybucket9658582"
  }
  force_destroy = true
}

output "opbucket" {
  value = aws_s3_bucket.bucket
}

locals {
  s3_origin_id = "S3-Mybucket9658582"
}

###buckets origin_access_id####
resource "aws_cloudfront_origin_access_identity" "origin_access_identity_b" {
  comment = "try1"
}

output "policy" {
    value = "aws_cloudfront_origin_access_identity.origin_access_identity_bucket"
}
###pulling access id###

##cloudfront##
resource "aws_cloudfront_distribution" "s3_distribution" {
  
  depends_on = [
    aws_s3_bucket.bucket,
  ]
  
  origin {
    domain_name = "${aws_s3_bucket.bucket.bucket_regional_domain_name}"
    origin_id   = "${local.s3_origin_id}"
    s3_origin_config {
  origin_access_identity = "${aws_cloudfront_origin_access_identity.origin_access_identity_b.cloudfront_access_identity_path}"
    }
 }

  enabled             = true
  is_ipv6_enabled     = true
  
  default_cache_behavior {
    allowed_methods  = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = "${local.s3_origin_id}"
    forwarded_values {
    query_string = false

      cookies {
        forward = "none"
      }
    }
    viewer_protocol_policy = "allow-all"
    min_ttl                = 0
    default_ttl            = 3600
    max_ttl                = 86400
  }

  # Cache behavior with precedence 0
  ordered_cache_behavior {
    path_pattern     = "/content/immutable/*"
    allowed_methods  = ["GET", "HEAD", "OPTIONS"]
    cached_methods   = ["GET", "HEAD", "OPTIONS"]
    target_origin_id = "${local.s3_origin_id}"

    forwarded_values {
      query_string = false
      headers      = ["Origin"]

      cookies {
        forward = "none"
      }
    }

    min_ttl                = 0
    default_ttl            = 86400
    max_ttl                = 31536000
    compress               = true
    viewer_protocol_policy = "allow-all"
  }
  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  # Cache behavior with precedence 1
  ordered_cache_behavior {
    path_pattern     = "/content/*"
    allowed_methods  = ["GET", "HEAD", "OPTIONS"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = "${local.s3_origin_id}"

    forwarded_values {
      query_string = false

      cookies {
        forward = "none"
      }
    }

    min_ttl                = 0
    default_ttl            = 3600
    max_ttl                = 86400
    compress               = true
    viewer_protocol_policy = "allow-all"
  }
  
  tags = {
    Environment = "production"
  }

  viewer_certificate {
    cloudfront_default_certificate = true
  }
}

##Getting the output for the CDN##
output "opcdn" {
  value = aws_cloudfront_distribution.s3_distribution
}


###setting new rules in the bucket policy###
data "aws_iam_policy_document" "s3_policy" {
  statement {
    actions   = ["s3:GetObject"]
    resources = ["${aws_s3_bucket.bucket.arn}/*"]

    principals {
      type        = "AWS"
      identifiers = ["${aws_cloudfront_origin_access_identity.origin_access_identity_b.iam_arn}"]
    }
  }

/*
  statement {
    actions   = ["s3:ListBucket"]
    resources = ["${aws_s3_bucket.bucket.arn}"]

    principals {
      type        = "AWS"
      identifiers = ["${aws_cloudfront_distribution.s3_distribution.cloudfront_access_identity_path}"]
    }
  }
*/
}
####bucket policy####
resource "aws_s3_bucket_policy" "bucket_policy" {
  
  bucket = "${aws_s3_bucket.bucket.id}"
  policy = "${data.aws_iam_policy_document.s3_policy.json}"
}


####///to upload the data after making rule in the bucket///####
resource "aws_s3_bucket_object" "object" {
  
  depends_on = [
    aws_cloudfront_distribution.s3_distribution,
  ]
  
  bucket = "${aws_s3_bucket.bucket.id}"
  key    = "lad.jpg"
  source  = "file/lad.jpg"
  acl = "public-read-write"
  content_type = "image/jpg"

  # The filemd5() function is available in Terraform 0.11.12 and later
  # For Terraform 0.11.11 and earlier, use the md5() function and the file() function:
  # etag = "${md5(file("path/to/file"))}"
  etag = "${filemd5("file/lad.jpg")}"
}

###changing the filename in the code###
resource "null_resource" "filenamechange" {
  # ...
  depends_on = [
    aws_s3_bucket_object.object,
  ]
  
  connection  {
          type = "ssh"
          user = "ec2-user"
          private_key = file("C:/Users/Akshat/Desktop/ukey1.pem")
          host = aws_instance.inst1.public_ip
  }
/*  
  provisioner "remote-exec" {
    inline = [
	  #sudo su << \"EOF\" \n echo \ "<img src='{$selfdomainname}'>\" >> /var/www/html/index.html \n \"EOF\""
	  "sudo su << EOF",
	  "echo \"<img src='http://${aws_cloudfront_distribution.s3_distribution.domain_name}/${aws_s3_bucket_object.object.key} height='500' width='800' />\" >> /var/www/html/index.html" ,
                     "EOF"
	]	
  }
*/
  provisioner "remote-exec" {
    inline = [
	  #sudo su << \"EOF\" \n echo \ "<img src='{$selfdomainname}'>\" >> /var/www/html/index.html \n \"EOF\""
	  "sudo sed 's+url+http://${aws_cloudfront_distribution.s3_distribution.domain_name}/${aws_s3_bucket_object.object.key}+g' /var/www/html/index.php"
	]	
  }
  
}

###///connecting to the ip///###
resource "null_resource" "chrome" {
  # ...
  depends_on = [
    aws_s3_bucket_object.object,
  ]
  
  provisioner "local-exec" {
    command = "start chrome ${aws_instance.inst1.public_ip}"
  }
}

/*
*/
