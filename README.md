# AWS Wordpress Infra

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

## 1  VPC e Subnets
Neste repositório há um arquivo chamado vpc-template.yaml, com ele podemos acessar o serviço do Cloud Formation e solicitar a criação de uma Stack usando esse template.


<img width="1915" height="164" alt="image" src="https://github.com/user-attachments/assets/58bc150b-68cf-4b1c-9510-f1c97ae5412b" />

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
