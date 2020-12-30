resource "aws_instance" "react_calculator_ec2" {
  instance_type = "t2.micro"
  ami           = "ami-05ec0d2eeb9187f51"
  tags = {
    Name = var.ec2_name
  }
  key_name               = aws_key_pair.react_calculator_key_pair.id
  vpc_security_group_ids = [aws_security_group.react_calculator_sg.id]
  user_data              = <<-EOF
              #!/bin/bash
              apt-get update && apt-get upgrade -y && apt-get autoremove && apt-get autoclean 2>&1 | tee output-apt-install.txt
              apt-get -y install git 2>&1 | tee output-git-install.txt 
              apt-get -y install nodejs 2>&1 | tee output-node-install.txt
              apt-get -y install npm 2>&1 | tee output-npm-install.txt
              cd /root
              echo "I came here" > here.txt
              echo $(whoami) > here1.txt
              git clone https://github.com/pranavprem/ReactCalculator.git 2>&1 | tee output-git.txt
              echo "this also happened" >> here2.text
              cd ReactCalculator
              npm install 2>&1 | tee output-npm.log
              npm run dev 2>&1 | tee run-dev-output.log
              EOF

}
