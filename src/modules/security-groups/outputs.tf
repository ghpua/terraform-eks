// External SSH allows ssh connections on port 22 from the world.
output "external_ssh" {
  value = "${aws_security_group.external_ssh.id}"
}

output "sg_id_masters" {
  description = "ID of the security group for the EKS cluster."
  value       = "${aws_security_group.masters.id}"
}

output "sg_id_workers" {
  description = "ID of the security group for the works ASG."
  value       = "${aws_security_group.workers.id}"
}
