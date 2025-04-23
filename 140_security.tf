########################################
# Network ACL - Public Subnet (Honeypot)
########################################
resource "aws_network_acl" "tender_trap_public_nacl" {
  vpc_id = aws_vpc.tender_trap_vpc.id
  subnet_ids = [aws_subnet.tender_trap_public.id]

  tags = merge(local.common_tags, {
    Name = "tender-trap-public-nacl"
  })
}

# Inbound Rules
resource "aws_network_acl_rule" "public_inbound_ssh_fake" {
  network_acl_id = aws_network_acl.tender_trap_public_nacl.id
  rule_number    = 100
  egress         = false
  protocol       = "tcp"
  rule_action    = "allow"
  cidr_block     = "0.0.0.0/0"
  from_port      = 22
  to_port        = 22
}

resource "aws_network_acl_rule" "public_inbound_ssh_admin" {
  network_acl_id = aws_network_acl.tender_trap_public_nacl.id
  rule_number    = 110
  egress         = false
  protocol       = "tcp"
  rule_action    = "allow"
  cidr_block     = var.ssh_ingress_ip
  from_port      = 2222
  to_port        = 2222
}

resource "aws_network_acl_rule" "public_inbound_http" {
  network_acl_id = aws_network_acl.tender_trap_public_nacl.id
  rule_number    = 120
  egress         = false
  protocol       = "tcp"
  rule_action    = "allow"
  cidr_block     = "0.0.0.0/0"
  from_port      = 80
  to_port        = 80
}

resource "aws_network_acl_rule" "public_inbound_https" {
  network_acl_id = aws_network_acl.tender_trap_public_nacl.id
  rule_number    = 130
  egress         = false
  protocol       = "tcp"
  rule_action    = "allow"
  cidr_block     = "0.0.0.0/0"
  from_port      = 443
  to_port        = 443
}

resource "aws_network_acl_rule" "public_inbound_tcp_ephemeral" {
  rule_number    = 141
  egress         = false
  protocol       = "tcp"
  rule_action    = "allow"
  cidr_block     = "0.0.0.0/0"
  from_port      = 1024
  to_port        = 65535
  network_acl_id = aws_network_acl.tender_trap_public_nacl.id
}

resource "aws_network_acl_rule" "public_inbound_udp_ephemeral" {
  rule_number    = 151
  egress         = false
  protocol       = "udp"
  rule_action    = "allow"
  cidr_block     = "0.0.0.0/0"
  from_port      = 1024
  to_port        = 65535
  network_acl_id = aws_network_acl.tender_trap_public_nacl.id
}

resource "aws_network_acl_rule" "public_inbound_icmp" {
  rule_number    = 161
  egress         = false
  protocol       = "icmp"
  rule_action    = "allow"
  cidr_block     = "0.0.0.0/0"
  from_port      = -1
  to_port        = -1
  network_acl_id = aws_network_acl.tender_trap_public_nacl.id
}

# Outbound Rules (Allow All)
resource "aws_network_acl_rule" "public_outbound_all" {
  network_acl_id = aws_network_acl.tender_trap_public_nacl.id
  rule_number    = 100
  egress         = true
  protocol       = "-1"
  rule_action    = "allow"
  cidr_block     = "0.0.0.0/0"
  from_port      = 0
  to_port        = 0
}

########################################
# Network ACL - Private Subnet (Monitor)
########################################
resource "aws_network_acl" "tender_trap_private_nacl" {
  vpc_id     = aws_vpc.tender_trap_vpc.id
  subnet_ids = [aws_subnet.tender_trap_private.id]

  tags = merge(local.common_tags, {
    Name = "tender-trap-private-nacl"
  })
}

# Inbound Rules
resource "aws_network_acl_rule" "private_inbound_ssh" {
  network_acl_id = aws_network_acl.tender_trap_private_nacl.id
  rule_number    = 100
  egress         = false
  protocol       = "tcp"
  rule_action    = "allow"
  cidr_block     = "0.0.0.0/0"
  from_port      = 22
  to_port        = 22
}

resource "aws_network_acl_rule" "private_inbound_syslog" {
  network_acl_id = aws_network_acl.tender_trap_private_nacl.id
  rule_number    = 110
  egress         = false
  protocol       = "tcp"
  rule_action    = "allow"
  cidr_block     = var.public_subnet_cidr
  from_port      = 514
  to_port        = 514
}

resource "aws_network_acl_rule" "private_inbound_tcp_ephemeral" {
  rule_number    = 121
  egress         = false
  protocol       = "tcp"
  rule_action    = "allow"
  cidr_block     = "0.0.0.0/0"
  from_port      = 1024
  to_port        = 65535
  network_acl_id = aws_network_acl.tender_trap_private_nacl.id
}

resource "aws_network_acl_rule" "private_inbound_udp_ephemeral" {
  rule_number    = 131
  egress         = false
  protocol       = "udp"
  rule_action    = "allow"
  cidr_block     = "0.0.0.0/0"
  from_port      = 1024
  to_port        = 65535
  network_acl_id = aws_network_acl.tender_trap_private_nacl.id
}

resource "aws_network_acl_rule" "private_inbound_icmp" {
  rule_number    = 141
  egress         = false
  protocol       = "icmp"
  rule_action    = "allow"
  cidr_block     = "0.0.0.0/0"
  from_port      = -1
  to_port        = -1
  network_acl_id = aws_network_acl.tender_trap_private_nacl.id
}

# Outbound Rules (Allow All)
resource "aws_network_acl_rule" "private_outbound_all" {
  network_acl_id = aws_network_acl.tender_trap_private_nacl.id
  rule_number    = 100
  egress         = true
  protocol       = "-1"
  rule_action    = "allow"
  cidr_block     = "0.0.0.0/0"
  from_port      = 0
  to_port        = 0
}


###################################
# Security Group - Honeypot
###################################
resource "aws_security_group" "tender_trap_honeypot_sg" {
  name        = "tender-trap-honeypot-sg"
  description = "Allow limited inbound for honeypot"
  vpc_id      = aws_vpc.tender_trap_vpc.id

  ingress {
    description = "Baited SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Real SSH for admin"
    from_port   = 2222
    to_port     = 2222
    protocol    = "tcp"
    cidr_blocks = [var.ssh_ingress_ip]
  }

  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTPS"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "Allow all outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(local.common_tags, {
    Name = "tender-trap-honeypot-sg"
  })
}

###################################
# Security Group - NAT Instance
###################################
resource "aws_security_group" "tender_trap_nat_sg" {
  name        = "tender-trap-nat-sg"
  description = "Allow all outbound for NAT"
  vpc_id      = aws_vpc.tender_trap_vpc.id

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [var.private_subnet_cidr]
  }
  
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.ssh_ingress_ip]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  tags = merge(local.common_tags, {
    Name = "tender-trap-nat-sg"
  })
}

###################################
# Security Group - Monitor Node
###################################
resource "aws_security_group" "tender_trap_monitor_sg" {
  name        = "tender-trap-monitor-sg"
  description = "Allow inbound syslog and SSH"
  vpc_id      = aws_vpc.tender_trap_vpc.id

  ingress {
    description = "SSH for administration"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.public_subnet_cidr]
  }

  ingress {
    description = "Syslog from honeypot"
    from_port   = 514
    to_port     = 514
    protocol    = "tcp"
    cidr_blocks = [var.public_subnet_cidr]
  }

  egress {
    description = "Allow all outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(local.common_tags, {
    Name = "tender-trap-monitor-sg"
  })
}
