resource "aws_key_pair" "eks" {
  key_name   = "roboshop-eks"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCfiOSZHB2m2S+HOJaBF+Y6qSLSbsl1XVA/+S1c9FSAHn1lnRs/c5zIx2SZKJcThth+c92x0UN36/5EcIFZlgIOVub3gklfH+11yHDEO2V4KGagqG5JgagnTQaAYu8XnQPN87Md/LGTfry4LIp8NQt6GLt5ndqSNzfuVssMiNVn1Tssg7pakMiaGSgJQaR8kwGS7jWrf4eHxjVqZ4JvZXhRIms2x//E8c7HyuxszVLbIJoYyGF3W1CE9Ek/IsZxoyyDs0+8rgzb1IdtRHq+WZ82dON1jjT5Qz2WOPzzaHO7siW62TEswrvoJlZ0THogJCVppimufbud+Gmu123OU3Pf prade@LAPTOP-M7BUC04F"
}

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 20.0"

  cluster_name    = local.name
  cluster_version = "1.32" # later we upgrade 1.32
  create_node_security_group = false
  create_cluster_security_group = false
  cluster_security_group_id = local.eks_control_plane_sg_id
  node_security_group_id = local.eks_node_sg_id

  #bootstrap_self_managed_addons = false
  cluster_addons = {
    coredns                = {}
    eks-pod-identity-agent = {}
    kube-proxy             = {}
    vpc-cni                = {}
    metrics-server = {}
  }

  # Optional
  cluster_endpoint_public_access = false

  # Optional: Adds the current caller identity as an administrator via cluster access entry
  enable_cluster_creator_admin_permissions = true

  vpc_id                   = local.vpc_id
  subnet_ids               = local.private_subnet_ids
  control_plane_subnet_ids = local.private_subnet_ids

  # EKS Managed Node Group(s)
  eks_managed_node_group_defaults = {
    instance_types = ["m6i.large", "t3.large", "m5n.large", "m5zn.large"]
  }

  eks_managed_node_groups = {
    #  blue = {
    #   # Starting on 1.30, AL2023 is the default AMI type for EKS managed node groups
    #   ami_type       = "AL2_x86_64"
    #   instance_types = ["t3.large"]
    #   key_name = aws_key_pair.eks.key_name

    #   min_size     = 2
    #   max_size     = 10
    #   desired_size = 2
    #   iam_role_additional_policies = {
    #     AmazonEBSCSIDriverPolicy = "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"
    #     AmazonEFSCSIDriverPolicy = "arn:aws:iam::aws:policy/service-role/AmazonEFSCSIDriverPolicy"
    #     AmazonEKSLoadBalancingPolicy = "arn:aws:iam::aws:policy/ElasticLoadBalancingFullAccess"
    #   }
    # }

    green = {
      # Starting on 1.30, AL2023 is the default AMI type for EKS managed node groups
      #ami_type       = "AL2_x86_64"
      instance_types = ["t3.large"]
      key_name = aws_key_pair.eks.key_name

      min_size     = 2
      max_size     = 10
      desired_size = 2
      iam_role_additional_policies = {
        AmazonEBSCSIDriverPolicy = "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"
        AmazonEFSCSIDriverPolicy = "arn:aws:iam::aws:policy/service-role/AmazonEFSCSIDriverPolicy"
        AmazonEKSLoadBalancingPolicy = "arn:aws:iam::aws:policy/ElasticLoadBalancingFullAccess"
      }
    }
  }

  tags = merge(
    var.common_tags,
    {
        Name = local.name
    }
  )
}