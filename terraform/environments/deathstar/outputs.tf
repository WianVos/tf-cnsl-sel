# this defines the outputs rendered by terraform if all is set and done

output "public_dns" {
  value = ["${aws_instance.deathstar_consul.*.public_dns}"]
}
