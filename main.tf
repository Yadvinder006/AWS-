resource "aws_vpc" "yadi_VPC" {
  cidr_block           = "10.120.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true


  tags = {

    Name = "dev"
  }
}

resource "aws_subnet" "yadi_subnet" {
  vpc_id                  = aws_vpc.yadi_VPC.id
  cidr_block              = "10.120.1.0/24"
  map_public_ip_on_launch = true
  availability_zone       = "ap-southeast-2a"

  tags = {
    Name = "Main"
  }
}

resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.yadi_VPC.id

  tags = {
    Name = "mygateway"
  }
}

resource "aws_route_table" "r" {
  vpc_id = aws_vpc.yadi_VPC.id

}

resource "aws_route" "defaut_route" {

  route_table_id         = aws_route_table.r.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.gw.id
}

resource "aws_route_table_association" "Ydi" {
  subnet_id      = aws_subnet.yadi_subnet.id
  route_table_id = aws_route_table.r.id


}

resource "aws_security_group" "allow_tls" {
  name        = "dev_SG"
  description = "dev security group"
  vpc_id      = aws_vpc.yadi_VPC.id

  ingress {
    description      = "TLS from VPC"
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
   
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
}
  resource "aws_key_pair" "newkey" {

      key_name = "newkey"
      public_key = file("~/.ssh/mykey.pub")
  }

  resource "aws_instance" "dev_node"  {
     instance_type = "t2.micro"
     ami = data.aws_ami.server_ami.id
     key_name = aws_key_pair.newkey.id
    vpc_security_group_ids = [aws_security_group.allow_tls.id]
    subnet_id = aws_subnet.yadi_subnet.id
    user_data = file("userdata.tpl")
   



  }