#!/bin/bash
yum update -y
yum install -y docker git jq aws-cfn-bootstrap amazon-efs-utils mariadb105

# Retrive credentials secret
SECRET_NAME="credentials"
REGION="us-east-1"
CREDENTIALS=$(aws secretsmanager get-secret-value --secret-id "$SECRET_NAME" --region "$REGION" --query SecretString --output text)
SECRET=$(echo "$CREDENTIALS" | jq -r '.credentials')

SECRET_ARR=(${SECRET//;/ })

export MYSQL_HOST=${SECRET_ARR[0]}
MYSQL_PASS=${SECRET_ARR[1]}

mysql --user=admin --password=$MYSQL_PASS

# Cria o diretório para o ponto de montagem
mkdir -p /wordpress/wp-content
EFS_ID="${EFSFileSystem}"
mount -t efs $EFS_ID:/ /wordpress/wp-content/

# Start Docker Service
systemctl start docker

# Install docker compose
curl -L "https://github.com/docker/compose/releases/download/v2.33.1/docker-compose-$(uname -s)-$(uname -m)"  -o /usr/local/bin/docker-compose
mv /usr/local/bin/docker-compose /usr/bin/docker-compose
chmod +x /usr/bin/docker-compose      

# Clone github repository
#git clone https://DellGarcia:$PAT@github.com/DellGarcia/aws-infra-challenge.git
git clone https://github.com/DellGarcia/aws-infra-challenge.git

# Create .env
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
/opt/aws/bin/cfn-signal -e 0 --stack ${AWS::StackName} --resource EC2AutoScalingGroup --region ${AWS::Region}