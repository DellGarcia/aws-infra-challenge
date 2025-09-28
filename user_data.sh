#!/bin/bash
yum update -y
yum install -y docker git jq aws-cfn-bootstrap amazon-efs-utils mariadb105

# Configure Database
export MYSQL_HOST=
MYSQL_PASS=
EFS_ID=

mysql --user=admin --password=

# Acho q tá errado...
# CREATE USER IF NOT EXISTS 'wordpress' IDENTIFIED BY 'wordpress-pass';
# GRANT ALL PRIVILEGES ON wordpress.* TO wordpress;
# FLUSH PRIVILEGES;
# CREATE DATABASE IF NOT EXISTS wordpress;
# EXIT

# Cria o diretório para o ponto de montagem
mkdir -p /wordpress/wp-content
#EFS_ID="${MyEFS}"
mount -t efs $EFS_ID:/ /wordpress/wp-content

# Start Docker Service
systemctl start docker

# Install docker compose
curl -L "https://github.com/docker/compose/releases/download/v2.33.1/docker-compose-$(uname -s)-$(uname -m)"  -o /usr/local/bin/docker-compose
mv /usr/local/bin/docker-compose /usr/bin/docker-compose
chmod +x /usr/bin/docker-compose      

# Retrive github secret
#SECRET_NAME="aws_infra_challenge_pat"
#REGION="us-east-1"
#GITHUB_PAT=$(aws secretsmanager get-secret-value --secret-id "$SECRET_NAME" --region "$REGION" --query SecretString --output text)
#PAT=$(echo "$GITHUB_PAT" | jq -r '.github_pat')

# Clone github repository
#git clone https://DellGarcia:$PAT@github.com/DellGarcia/aws-infra-challenge.git

# Test
cd ~
echo "DB_HOST=$MYSQL_HOST
DB_USER=admin
DB_PASSWORD=$MYSQL_PASS
DB_NAME=wordpress
" >> .env
mv .env /aws-infra-challenge
cd /
cd aws-infra-challenge


# Start docker compose
docker-compose up -d

# Success Signal for CloudFormation
# /opt/aws/bin/cfn-signal -e 0 --stack ${AWS::StackName} --resource EC2AutoScalingGroup --region ${AWS::Region}
