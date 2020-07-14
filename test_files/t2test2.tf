provider aws {
  region = "ap-south-1"
  profile = "derek"
}

##creating the security group2 for nfs server##
resource "aws_security_group" "security_group2" {
  name        = "allow_nfs"
  description = "Allow TCP and NFS inbound traffic"
  vpc_id      = "vpc-7b839e13"

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

##creating the security groups##
resource "aws_security_group" "security_group1" {
  name        = "allow_tcp"
  description = "Allow TCP and SSH inbound traffic"
  vpc_id      = "vpc-7b83e13"

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

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "sg1"
  }
}


output "op_security_group" {
  value = aws_security_group.security_group2
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
  subnet_id = "subnet-5753f"
}
resource "aws_efs_mount_target" "alphas" {
  depends_on = [
      aws_efs_file_system.efs
  ]
  file_system_id = aws_efs_file_system.efs.id
  security_groups = ["${aws_security_group.security_group2.id}"]
  subnet_id = "subnet-9fb"
}
resource "aws_efs_mount_target" "alphat" {
  depends_on = [
      aws_efs_file_system.efs
  ]
  file_system_id = aws_efs_file_system.efs.id
  security_groups = ["${aws_security_group.security_group2.id}"]
  subnet_id = "subnet-47"
}
/*
resource "aws_efs_mount_target" "efsmount2" {
    file_system_id = "${aws_efs_file_system.efs.id}"
    availability_zone = "ap-south-1b"
    security_groups = [ "allow_nfs" ]
}
*/

##setting variable for the key##
variable "insert_key_var" {
     type = string
//   default = "terask"
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
              "sudo mkdir -p /var/www/html",
              "sudo yum  install -y amazon-efs-utils",
              "sudo yum  install git -y",
              "sudo mount -t nfs4 -o nfsvers=4.1,rsize=1048576,wsize=1048576,hard,timeo=600,retrans=2,noresvport ${aws_efs_file_system.efs.dns_name}:/ /var/www/html/",
              "sudo su -c \"echo '${aws_efs_file_system.efs.dns_name}:/ /var/www/html nfs4 defaults,vers=4.1,rsize=1048576,wsize=1048576,hard,timeo=600,retrans=2,noresvport 0 0' >> /etc/fstab\"", 
              "sudo git clone https://github.com/akshat-crypto/HCC_Task1.git  /var/www/html",
          ]
      }
}

output "op_instances" {
  value = aws_instance.inst1
}
/*
 "sudo yum install -y git",
              "git clone https://github.com/aws/efs-utils",
              "sudo yum -y install make",
              "sudo yum -y install rpm-build",
              "sudo make rpm",
              "sudo yum -y install ./build/amazon-efs-utils*rpm",
*/
