

resource "aws_instance" "tender_trap_honeypot" {
  ami                         = var.ami_id
  instance_type               = var.instance_types["honeypot"]
  subnet_id                   = aws_subnet.tender_trap_public.id
  vpc_security_group_ids      = [aws_security_group.tender_trap_honeypot_sg.id]
  associate_public_ip_address = true
  key_name                    = var.key_pair_name

  tags = merge(local.common_tags, {
    Name = "tender-trap-honeypot"
  })
}

resource "aws_instance" "tender_trap_monitor" {
  ami                         = var.ami_id
  instance_type               = var.instance_types["monitor"]
  subnet_id                   = aws_subnet.tender_trap_private.id
  vpc_security_group_ids      = [aws_security_group.tender_trap_monitor_sg.id]
  associate_public_ip_address = false
  key_name                    = var.key_pair_name

  tags = merge(local.common_tags, {
    Name = "tender-trap-monitor"
  })
}