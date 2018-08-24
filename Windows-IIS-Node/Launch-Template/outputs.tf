output "ami_id" {
  value = "${data.aws_ami.TeamCity-BuildNode-IIS-Windows.id}"
}
