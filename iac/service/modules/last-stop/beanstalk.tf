module "beanstalk_security_group" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "~> 4.0"

  name   = "${var.name}-${terraform.workspace}-sg-id"
  vpc_id = data.aws_vpc.sg.id

  ingress_with_cidr_blocks = [
    {
      from_port   = 80
      to_port     = 80
      protocol    = "tcp"
      description = "Unencrypted Traffic"
      cidr_blocks = "10.0.0.0/16"
    },
    {
      from_port   = 443
      to_port     = 443
      protocol    = "tcp"
      description = "Encrypted Traffic"
      cidr_blocks = "10.0.0.0/16"
    }
  ]

  egress_with_cidr_blocks = [
    {
      from_port   = 80
      to_port     = 80
      protocol    = "tcp"
      description = "Unencrypted Traffic"
      cidr_blocks = "10.0.0.0/16"
    },
    {
      from_port   = 443
      to_port     = 443
      protocol    = "tcp"
      description = "Encrypted Traffic"
      cidr_blocks = "10.0.0.0/16"
    }
  ]
}


resource "aws_elastic_beanstalk_application" "last_stop_app" {
  name        = var.name
  description = "Internal DLP Solution"
}

resource "aws_elastic_beanstalk_environment" "last_stop_environment" {
  name                = "${var.name}-${terraform.workspace}"
  application         = aws_elastic_beanstalk_application.last_stop_app.name
  solution_stack_name = "64bit Amazon Linux 2 v3.4.8 running Node.js 18"

  setting {
    namespace = "aws:autoscaling:launchconfiguration"
    name      = "IamInstanceProfile"
    value     = "aws-elasticbeanstalk-ec2-role"
  }

  setting {
    namespace = "aws:autoscaling:launchconfiguration"
    name      = "InstanceType"
    value     = "t2.micro"
  }

  setting {
    namespace = "aws:autoscaling:launchconfiguration"
    name      = "SecurityGroups"
    value     = module.beanstalk_security_group.security_group_id
  }

  setting {
    namespace = "aws:ec2:vpc"
    name      = "VPCId"
    value     = data.aws_vpc.last_stop.id
  }

  setting {
    namespace = "aws:ec2:vpc"
    name      = "Subnets"
    value     = join(",", )
  }

  setting {
    namespace = "aws:ec2:vpc"
    name      = "AssociatePublicIpAddress"
    value     = "false"
  }

  setting {
    namespace = "aws:elasticbeanstalk:environment"
    name      = "EnvironmentType"
    value     = "LoadBalanced"
  }

  setting {
    namespace = "aws:elasticbeanstalk:application"
    name      = "Application Healthcheck URL"
    value     = "/"
  }
}