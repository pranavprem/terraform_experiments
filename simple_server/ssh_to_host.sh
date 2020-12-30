rm -rf ~/react_calculator_key_pair.pem
terraform output private_key | sed '$d' | sed '$d' | sed '1d' > ~/react_calculator_key_pair.pem
chmod 400 ~/react_calculator_key_pair.pem
ssh -i "~/react_calculator_key_pair.pem" bitnami@$(terraform output public_dns | sed 's/"//g')