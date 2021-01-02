curl -X GET $(terraform output alb_dns_name |  sed 's/"//g')
