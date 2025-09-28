# ☁️ AWS Wordpress Cloud Infra ☁️

Este projeto tem como objetivo realizar a implantação de uma infraestrutura para uma aplicação wordpress na AWS, o objetivo é utilizar os serviços e ferramentas da AWS para tornar a aplicação e seus dados seguros e com alta disponibilidade. Segue abaixo o diagrama da infraestrutura a ser construída:

<img width="1381" height="607" alt="image" src="https://github.com/user-attachments/assets/74b1015d-c4a6-432a-bbb2-5e28a8694bb8" />

## ⚙️ Cloud Formation
Para este projeto utilizei o AWS Cloud Formation para automatizar a criação de alguns recursos, neste guia de instalação vou explicar como preparar a infra estrutura usando o Cloud Formation e também como fazer manualmente caso tenham interesse em saber como a mágica aconteceu.

<details>
    <summary><h2>Como criar uma Stack no Cloud Formation (YAML)<h2/></summary>
    
No console da AWS procure pelo serviço Cloud Formation, ao clicar nele será recepcionado com uma tela semelhante a imagem a abaixo, onde poderá clickar em "Create Stack":

<img width="1302" height="289" alt="image" src="https://github.com/user-attachments/assets/67080af4-e625-4e2c-aefe-92cf424b070d" />

Na tela seguinte selecione a opção "Choose an existing template", depois "Upload a template file", então click em "Choose File" e selecione o template que deseja executar.

<img width="1400" height="690" alt="image" src="https://github.com/user-attachments/assets/5bac44ee-e870-4ff1-9574-323e844ed3a4" />

Avance para a próxima tela, dê um nome para a Stack e preencha os parametros solicitados caso haja.

Feito isso o resto é opcional, recomendo dar uma lida nas opções, mas pode deixar no padrão se quiser.

<img width="1387" height="475" alt="image" src="https://github.com/user-attachments/assets/f1f467ec-02d8-4adc-8c54-920d3e5596ff" />
</details>

# Etapas do Projeto:
As seguintes etapas serão necessárias para colocar o projeto para funcionar.

1. VPC e Subnets
2. Security Groups
3. Banco de Dados RDS
4. Secrets Manager
5. Lauch Template / Load Balancer / Auto Scaling 

Obs: É importante lembrar que os recursos criados aqui vão gerar custos, então depois quando não for usar mais lembre de deletar os recursos criados.

## Etapa 1 - VPC e Subnets
Neste repositório há um arquivo chamado vpc-template.yaml, com ele podemos acessar o serviço do Cloud Formation e solicitar a criação de uma Stack usando esse template.
Basta dar um nome para a Stack e dar um nome para a VPC que vai ser criada, o template vai criar 1 VPC com 6 Subnets (2 públicas e 4 privadas) distribuidas em 2 AZs.

As subnets criadas vão ser númeradas para facilitar a identificação, para este projeto segui a seguinte regra para a utlização das subnets:

### Subnets Públicas 1 e 2:
Elas por serem públicas tem um internet gateway que permite acesso a internet, por isso nela serão anexados apenas:

1. NAT Gatways
2. Load Balancer
3. Bastion Host.

### Subnets Privadas 1 e 2:
Destinadas para as instancias EC2 que vão executar a aplicação Wordpress, junto a elas estará o Auto Scaling Group.

### Subnets Privadas 3 e 4: 
São voltadas para os dados, ou seja aqui ficará o banco de dados do RDS e os mount targets do EFS.


<details>
    <summary><h3>Como criar a VPC e Subnets no Console<h3></summary>

A AWS oferece um forma de automatizar isso, basta acessar a página do serviço VPC, acessar a aba VPCs ou Your VPCs e então clicar em criar VPC.

<img width="791" height="161" alt="image" src="https://github.com/user-attachments/assets/02d2bc60-6e2b-472c-9744-96b156503b33" />

Então siga os passos abaixo:

1. Selecine VPC and more
2. Coloque um nome para a VPC por exemplo AWS-Infra
3. No item "Number of private subnets" selecione 4
4. Em "NAT gateways ($)" selecione 1 per AZ
5. Em VPC endpoints selecione None
6. Clique em "Create VPC"

Com isso será criado a VPC com 2 subnets públicas cada uma com 1 NAT Gateway, 2 subnets privadas que serão usadas pelas instancias ec2 criadas pelo Auto Scaling e mais 2 subnets privadas destinadas para o banco de dados RDS e para montar o sistema de arquivos EFS.

</details>

## Etapa 2 - Security Groups
O arquivo security-groups-template.yaml automatiza a criação e configuração de todos os security groups que serão criados, basta executá-lo Cloud Formation.
Os parâmetros necessário são ID da VPC e qual IP terá permissão para acessar o Bastion Host.

<img width="1396" height="569" alt="image" src="https://github.com/user-attachments/assets/d855a761-ee7d-4363-b88e-7e65217c6afd" />

<details>
<summary><h3>Security Groups pelo Console<h3/></summary>
    
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

# Etapa 3 - Banco de Dados RDS
Aqui não criei um template do Cloud Formation, mas caso tenha interesse também é possivel automatizar essa parte.
Vou seguir apenas com o passo a passo da criação pelo console.

Accese no console o serviço "Aurora and RDS", primeiro precisamos criar um BD Subnet Group:

1. Acesse a aba "Subnet Groups".
2. Clique em "Create DB subnet group".
3. De um nome ao grupo escolha a VPC criada nos passos anteriores.
4. Escolha as Avalailabilitis Zones.
5. Em Subnets escolha as subnets privadas 3 e 4 (Subnets destinadas aos dados).
6. Clique em create.

Após isso acesse a aba database, clique em "Create Database" e siga os passo abaixo:

1. Deixe o método de criação em padrão.
2. Escolha o banco de dados MySQL.
3. Em templates escolha "Free Tier".
4. Em "Settings" de um nome ao seu database.
5. Master Username coloque admin.
6. Credentials Manager escolha "Self Managed".
7. Pode marcar a caixa "auto generate password" ou coloque uma senha de sua preferência.
8. Em Connectivity selecione a VPC e Subnet criadas anteriormente.
9. Em Security Group selecione "Database-SG-AWS-Infra".
10. Em Additional Configuration coloque o nome wordpress em "Initial database name".
11. Desmarque backups e encryption.
12. Clique em create database.

Com isso o banco dedos será criado e ao finalizar ele vai informar qual o endereço para acesar e qual a senha caso ele tenha gerado. 
Salve os dois vão ser necessário no próximo passo.
