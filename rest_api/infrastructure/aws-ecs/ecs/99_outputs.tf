output "load_balancer_ip" {
  value = aws_lb.api_lb.dns_name
}
