name = "last-stop"

### Create a VPC specifically for this project if you don't already have one
create_vpc = true

### Use an existing VPC that already has the network piping
# create_vpc = false
# vpc_config = {
# vpc_id = ""
# public_subnet_ids = []
# private_subnet_ids = []
# default_sg_id = ""
# }

# These allowlists enable access to the website. 
allowlistRangeIPv4 = ["10.0.0.0/16"]
allowlistRangeIPv6 = ["2001:db8:3333:4444:5555:6666:7777:8888/128"]
