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

<details>
<summary><h2>Security Groups<h2/></summary>
    
Os grupos de segurança são um dos pricinpais componentes para o funcionamento da infrastutura, sem eles basicamente não haveria comunicação entre os diferentes serviços, o ideal é isolar os pricipais recursos em security groups diferentes e só liberar acesso aos grupos necessários e apenas aos recursos necessários.

1. Bastion-SG-AWS-Infra
2. LoadBalancer-SG-AWS-Infra
3. Instance-SG-AWS-Infra
4. Database-SG-AWS-Infra
5. EFS-SG-AWS-Infra

### 1 - Bastion Security Group
O Bastion será o meio disponibilizado para acessar as instancias privadas via SSH, basicamente será uma instancia EC2 que servirá como ponte. Para isso precisamos criar um regra de entrada que permita acesso na porta 22 de preferencia litando apenas ao seu IP, dessa forma só você poderá acessar o Bastion, a regra de entrada ficará como na imagem abaixo:

<img width="896" height="348" alt="image" src="https://github.com/user-attachments/assets/271da61c-d069-4bbb-bdea-acf5a9f926c5" />

### 2 - Load Balancer Security Group
Esse security group será resposável por permitir acesso HTTP ao Load Balancer de qualquer endereço IPv4. A regra ficará como demonstrado na imagem abaixo:

<img width="896" height="348" alt="image" src="https://github.com/user-attachments/assets/ec247420-07e1-4f3f-8172-905244bd5637" />

### 3 - Instance Security Group
Security Group para as instancias EC2 que conterão a aplicação Wordpress, nela serão criada duas regras de entrada uma para SSH permitindo acesso para o grupo do Bastion e uma HTTP permitndo acesso do Load Balancer. Ficando da seguinte forma:

<img width="896" height="576" alt="image" src="https://github.com/user-attachments/assets/eaaa08f3-faa9-401b-938f-acbb6cbe5b59" />

## 4 - Banco de Dados RDS
Esse security group libera acesso ao mysql para as instancias EC2 do worpress:

<img width="903" height="307" alt="image" src="https://github.com/user-attachments/assets/dbc07304-af3c-4941-8569-65692e0c8005" />

## 5 - Sistema de arquivos EFS
Security Group para liberar acesso das instancias EC2 usarem o sistema de arquivos do EFS.

<img width="903" height="307" alt="image" src="https://github.com/user-attachments/assets/953d2096-cfff-4c45-a517-a46e544d08e0" />

</details>
