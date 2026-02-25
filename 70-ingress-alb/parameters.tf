resource "aws_ssm_parameter" "ingress_alb_listener_arn" {
    name = "/${var.project_name}/${var.environment}/ingress_alb_listener_arn"
    type = "String"
    value = aws_alb_listener.https.arn
}