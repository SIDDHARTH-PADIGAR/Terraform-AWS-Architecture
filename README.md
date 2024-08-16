## Architecture Overview
 
![AWSNetworking drawio](https://github.com/user-attachments/assets/48336c0c-91fa-445c-98ce-a0162a66eb10)


***This Terraform configuration sets up a basic AWS infrastructure within the us-east-2 region, featuring a Virtual Private Cloud (VPC) with both public and private subnets, as well as EC2 instances and associated resources.***

**Components**

-**VPC:**

A VPC is created with a CIDR block of 10.0.0.0/16, providing the networking foundation for the architecture.
Subnets:

-**Public Subnet:**

Located within the 10.0.0.0/24 range, this subnet is configured to automatically assign public IPs to instances for internet access.
Private Subnet: Located within the 10.0.1.0/24 range, this subnet is isolated from the internet, intended for instances that do not require direct external access.

-**Security Groups:**

Public Security Group (PublicSGProd): Allows SSH access (port 22) from anywhere (0.0.0.0/0), facilitating management of the public EC2 instance.
Private Security Group (PrivateSGProd): Restricts access to only the internal VPC range, ensuring that private instances are secure and accessible only within the network.

-**EC2 Instances:**

--**Public EC2 Instance:** A t2.micro instance in the public subnet, with a public IP for direct internet access.
--**Private EC2 Instance:** A t2.micro instance in the private subnet, without a public IP, secured by the private security group.

-**Internet Gateway:**

An Internet Gateway (IGW) is attached to the VPC, enabling internet access for resources within the public subnet.

-**Route Tables:**

--**Public Route Table (RTProd):** Configured to direct all outbound traffic (0.0.0.0/0) from the public subnet to the Internet Gateway.
--**Private Route Table:** Configured to route internet-bound traffic from the private subnet through a NAT Gateway, enabling outbound connectivity while maintaining inbound isolation.

-**NAT Gateway:**

A NAT Gateway is created in the public subnet, allowing instances in the private subnet to access the internet without exposing them to inbound traffic.
Elastic IP:

An Elastic IP (EIP) is associated with the NAT Gateway to provide a static IP address for outgoing traffic.
This architecture provides a foundational setup with a mix of public and private resources, suitable for applications requiring both external exposure and internal processing layers.

***This architecture provides a foundational setup with a mix of public and private resources, suitable for applications requiring both external exposure and internal processing layers.***


