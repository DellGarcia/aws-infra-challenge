# 🎉 Desafio de infraestrutura na AWS

Este projeto tem como objetivo realizar a implantação de uma infraestrutura para uma aplicação wordpress na AWS, o objetivo é utilizar os serviços e ferramentas da AWS para tornar a aplicação e seus dados seguros e com alta disponibilidade. Segue abaixo o diagrama da infraestrutura a ser construída:

<img width="1381" height="607" alt="image" src="https://github.com/user-attachments/assets/74b1015d-c4a6-432a-bbb2-5e28a8694bb8" />

# Etapas do Projeto:
As seguintes etapas serão necessárias para colocar o projeto para funcionar.

1. VPC e Subnets
2. Security Groups
3. Banco de Dados RDS
4. Sistema de Arquivos EFS
5. Instancia Bastion Host
6. Lauch Template
7. Target Group
8. Load Balancer
9. Auto Scaling Group

Obs: É importante lembrar que os recursos criados aqui vão gerar custos, então depois quando não for usar mais lembre de deletar os recursos criados.


## VPC e Subnets
    
Uma VPC é um serviço da AWS que permite criar uma rede isolada e privada, uma VPC atua dentro de uma AWS Region, ou seja, se criada em uma região por exemplo "us-east-1" ela não será visível em outras regiões, para este projeto utilzei "us-east-1".

**Obs: alguns serviços não estão disponíveis em todas as regiões da AWS**.

### Como criar a VPC e Subnets

Felizmente esse é um passo bem tranquilo já que a AWS oferece um forma de automatizar isso, basta acessar a página do serviço VPC, acessar a aba VPCs ou Your VPCs e então clicar em criar VPC.

<img width="791" height="161" alt="image" src="https://github.com/user-attachments/assets/02d2bc60-6e2b-472c-9744-96b156503b33" />

Então siga os passos abaixo:

1. Selecine VPC and more
2. Coloque um nome para a VPC por exemplo AWS-Infra
3. No item "Number of private subnets" selecione 4
4. Em "NAT gateways ($)" selecione 1 per AZ
5. Em VPC endpoints selecione None
6. Clique em "Create VPC"

Com isso será criado a VPC com 2 subnets públicas cada uma com 1 NAT Gateway, 2 subnets privadas que serão usadas pelas instancias ec2 criadas pelo Auto Scaling e mais 2 subnets privadas destinadas para o banco de dados RDS e para montar o sistema de arquivos EFS.

## Security Groups
Os grupos de segurança são um dos pricinpais componentes para o funcionamento da infrastutura, sem eles basicamente não haveria comunicação entre os diferentes serviços, o ideal é isolar os pricipais recursos em security groups diferentes e só liberar acesso aos grupos necessários e apenas aos recursos necessários.

1. Bastion-SG-AWS-Infra
2. LoadBalancer-SG-AWS-Infra
3. Instance-SG-AWS-Infra
4. Database-SG-AWS-Infra
5. EFS-SG-AWS-Infra

### 1 - Bastion Security Group
O Bastion será o meio disponibilizado para acessar as instancias privadas via SSH, basicamente será uma instancia EC2 que servirá como ponte. Para isso precisamos criar um regra de entrada que permita acesso na porta 22 de preferencia litando apenas ao seu IP, dessa forma só você poderá acessar o Bastion, a regra de entrada ficará como na imagem abaixo:

<img width="896" height="348" alt="image" src="https://github.com/user-attachments/assets/271da61c-d069-4bbb-bdea-acf5a9f926c5" />


## Banco de Dados RDS

## Sistema de arquivos EFS
