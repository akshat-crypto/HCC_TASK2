provider aws {
  region = "ap-south-1"
  profile = "derek"
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
  subnet_id = "subnet-"
}
/*
resource "aws_efs_mount_target" "efsmount2" {
    file_system_id = "${aws_efs_file_system.efs.id}"
    availability_zone = "ap-south-1b"
    security_groups = [ "allow_nfs" ]
}
*/

##LAUNCHING AN INSTANCE##
resource "aws_instance" "inst1" {
    depends_on = [
      aws_efs_mount_target.alpha
  ]
  ami = "ami-0447a12f28fddb066"
  instance_type = "t2.micro"
  key_name = "ukey1.pem"
  security_groups = [ "allow_nfs" ]
  tags = {
    Name = "server1"
    Terraform = "true"
  }
  volume_tags = {
    Name = "test_efs"
    Terraform = "true"
  }
}
