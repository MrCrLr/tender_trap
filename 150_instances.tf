

resource "aws_instance" "tender_trap_honeypot" {
  ami                         = var.ami_id
  instance_type               = var.instance_types["honeypot"]
  subnet_id                   = aws_subnet.tender_trap_public.id
  vpc_security_group_ids      = [aws_security_group.tender_trap_honeypot_sg.id]
  associate_public_ip_address = false
  key_name                    = var.key_pair_name

  lifecycle {
    ignore_changes = [
      ami,
      user_data,
      associate_public_ip_address,
      subnet_id,
      tags
    ]
  }

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

  lifecycle {
    ignore_changes = [
      ami,
      user_data,
      associate_public_ip_address,
      subnet_id,
      tags
    ]
  }

  tags = merge(local.common_tags, {
    Name = "tender-trap-monitor"
  })
}

resource "aws_instance" "tender_trap_nat" {
  ami                    = var.ami_id
  instance_type          = var.instance_types["honeypot"]
  subnet_id              = aws_subnet.tender_trap_public.id
  associate_public_ip_address = false
  key_name               = var.key_pair_name
  vpc_security_group_ids = [aws_security_group.tender_trap_nat_sg.id]
  source_dest_check = false


  lifecycle {
    ignore_changes = [
      ami,
      user_data,
      associate_public_ip_address,
      subnet_id,
      tags
    ]
  }

  tags = merge(local.common_tags, {
    Name = "tender-trap-nat"
})

user_data = <<-EOF
              #!/bin/bash
              echo "net.ipv4.ip_forward = 1" >> /etc/sysctl.conf
              sysctl -p
              iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE
              apt-get update -y
              apt-get install -y iptables-persistent
              netfilter-persistent save
              EOF
}