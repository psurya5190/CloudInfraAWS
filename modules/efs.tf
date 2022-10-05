
data "aws_availability_zones" "available" {}

resource "aws_security_group" "efs" {
   name = "efs-sg"
   description= "Allos inbound efs traffic from ec2"
   vpc_id = var.vpc_id

   ingress {
     security_groups = [aws_security_group.jenkins_master_sg.id]
     from_port = 2049
     to_port = 2049 
     protocol = "tcp"
   }     
        
   egress {
     security_groups = [aws_security_group.jenkins_master_sg.id]
     from_port = 0
     to_port = 0
     protocol = "-1"
   }
 }


resource "aws_efs_file_system" "efs" {
   creation_token = "efs"
   performance_mode = "generalPurpose"
   throughput_mode = "bursting"
   encrypted = "true"
 tags = {
     Name = "EFS"
   }
 }

/*
resource "aws_efs_mount_target" "efs-mt" {
   count = length(data.aws_availability_zones.available.names)
   file_system_id  = aws_efs_file_system.efs.id
   subnet_id = aws_subnet.private_subnets[count.index].id
   security_groups = [aws_security_group.efs.id]
 }

 */