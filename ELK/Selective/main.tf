#Main Resource File
provider "aws"{
  region = "${var.region}"
  assume_role {
   role_arn = var.target_role_arn_string
  }
}


data aws_iam_policy_document "ec2_assume_role" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

data aws_iam_policy_document "s3_access" {
  statement {
    actions = ["s3:*"]
    resources = ["arn:aws:s3:::*"]
  }
}

resource "aws_iam_role" "ec2_iam_role" {

  name = "ec2_iam_role"

  assume_role_policy = "${data.aws_iam_policy_document.ec2_assume_role.json}"
}

resource "aws_iam_role_policy" "join_policy" {

  depends_on = ["aws_iam_role.ec2_iam_role"]
  name       = "join_policy"
  role       = "${aws_iam_role.ec2_iam_role.name}"

  policy = "${data.aws_iam_policy_document.s3_access.json}"
}

resource "aws_iam_instance_profile" "instance_profile" {

  name = "instance_profile"
  role = "${aws_iam_role.ec2_iam_role.name}"
}

resource "aws_instance" "elk" {
  count = var.isClustered ? 0 : 1

  ami           = var.ami
  instance_type = var.instance_type
  key_name              = var.key_pair_name
  vpc_security_group_ids = [aws_security_group.ec2_sg.id] # No security group will be created
  subnet_id           = var.subnet_id
  associate_public_ip_address = false

  iam_instance_profile = "${aws_iam_instance_profile.instance_profile.name}"

  
  root_block_device {
    volume_type          = var.storage_type
    delete_on_termination = true
    volume_size          = var.storage_size
  }
  
  user_data = <<-EOF
    #!/bin/bash
    ${file("install_jdk21.sh")}
    ${file("install_elk.sh")}
    ${file("configure_elk.sh")}
    EOF



  tags = {
    Name = var.instance_name
  }
}

resource "aws_instance" "elasticsearch" {
  count = var.isClustered ? 1 : 0
  ami                     = var.ami
  instance_type           = var.instance_type
  key_name                = var.key_pair_name
  vpc_security_group_ids  = [aws_security_group.ec2_sg.id] # No security group will be created
  subnet_id               = var.subnet_id

  associate_public_ip_address = false
  
  iam_instance_profile = "${aws_iam_instance_profile.instance_profile.name}"
  
  root_block_device {
    volume_type           = var.storage_type
    delete_on_termination = true
    volume_size           = var.storage_size
  }
  
  user_data = <<-EOF
    #!/bin/bash
    ${file("install_jdk21.sh")}
    ${file("install_elasticsearch.sh")}
    EOF

  tags = {
    Name = var.instance_name_elasticsearch
  }
}

resource "aws_instance" "elasticsearch-node-1" {
  count = var.isClustered ? 1 : 0

  ami                     = var.ami
  instance_type           = var.instance_type
  key_name                = var.key_pair_name
  vpc_security_group_ids  = [aws_security_group.ec2_sg.id] # No security group will be created
  subnet_id               = var.subnet_id

  associate_public_ip_address = false
  
  iam_instance_profile = "${aws_iam_instance_profile.instance_profile.name}"
  
  root_block_device {
    volume_type           = var.storage_type
    delete_on_termination = true
    volume_size           = var.storage_size
  }
  
  user_data = <<-EOF
    #!/bin/bash
    ${file("install_jdk21.sh")}
    ${file("install_node.sh")}
    EOF

  tags = {
    Name = var.instance_name_node
  }
}

resource "aws_instance" "elasticsearch-node-2" {
  count = var.isClustered ? 1 : 0

  ami                     = var.ami
  instance_type           = var.instance_type
  key_name                = var.key_pair_name
  vpc_security_group_ids  = [aws_security_group.ec2_sg.id] # No security group will be created
  subnet_id               = var.subnet_id

  associate_public_ip_address = false
  
  iam_instance_profile = "${aws_iam_instance_profile.instance_profile.name}"
  
  root_block_device {
    volume_type           = var.storage_type
    delete_on_termination = true
    volume_size           = var.storage_size
  }
  
  user_data = <<-EOF
    #!/bin/bash
    ${file("install_jdk21.sh")}
    ${file("install_node.sh")}
    EOF

  tags = {
    Name = var.instance_name_node2
  }
}



resource "aws_instance" "kibana" {
  count = var.isClustered ? 1 : 0

  ami                     = var.ami
  instance_type           = var.instance_type
  key_name                = var.key_pair_name
  vpc_security_group_ids  = [aws_security_group.ec2_sg.id] # No security group will be created
  subnet_id               = var.subnet_id
  
  associate_public_ip_address = false

  iam_instance_profile = "${aws_iam_instance_profile.instance_profile.name}"

  root_block_device {
    volume_type           = var.storage_type
    delete_on_termination = true
    volume_size           = var.storage_size
  }
  
  user_data = <<-EOF
    #!/bin/bash
    echo "Elasticsearch-IP: ${aws_instance.elasticsearch[0].private_ip}" >> /home/ubuntu/user_data_output.txt
    ${file("install_kibana.sh")}
    EOF

  depends_on = [
    aws_instance.elasticsearch[0]
  ]

  tags = {
    Name = var.instance_name_kibana
  }
}

resource "aws_instance" "logstash" {
  count = var.isClustered ? 1 : 0

  ami                     = var.ami
  instance_type           = var.instance_type
  key_name                = var.key_pair_name
  vpc_security_group_ids  = [aws_security_group.ec2_sg.id] # No security group will be created
  subnet_id               = var.subnet_id
  
  associate_public_ip_address = false

  iam_instance_profile = "${aws_iam_instance_profile.instance_profile.name}"

  root_block_device {
    volume_type           = var.storage_type
    delete_on_termination = true
    volume_size           = var.storage_size
  }
  
  user_data = <<-EOF
    #!/bin/bash
    echo "Elasticsearch-IP: ${aws_instance.elasticsearch[0].private_ip}" >> /home/ubuntu/user_data_output.txt
    ${file("install_logstash.sh")}
    EOF

  depends_on = [
    aws_instance.elasticsearch[0]
  ]

  tags = {
    Name = var.instance_name_logstash
  }
}

