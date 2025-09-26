# 🎉 Desafio de infraestrutura na AWS

Este projeto tem como objetivo realizar a implantação de uma infraestrutura para uma aplicação wordpress na AWS, o objetivo é utilizar os serviços e ferramentas da AWS para tornar a aplicação e seus dados seguros e com alta disponibilidade. Segue abaixo o diagrama da infraestrutura a ser construída:

<img width="1381" height="607" alt="image" src="https://github.com/user-attachments/assets/74b1015d-c4a6-432a-bbb2-5e28a8694bb8" />

# Etapas do Projeto:
As seguintes etapas serão necessárias para colocar o projeto para funcionar.

1. VPC e Subnets
2. Banco de Dados
3. Sistema de Arquivos EFS
4. Instancia Bastion Host
5. Lauch Template
6. Target Group
7. Load Balancer
8. Auto Scaling Group

Obs: É importante lembrar que os recursos criados aqui vão gerar custos, então depois quando não for usar mais lembre de deletar os recursos criados.


## VPC e Subnets
    
Uma VPC é um serviço da AWS que permite criar uma rede isolada e privada, uma VPC atua dentro de uma AWS Region, ou seja, se criada em uma região por exemplo "us-east-1" ela não será visível em outras regiões, para este projeto utilzei "us-east-1".

**Obs: alguns serviços não estão disponíveis em todas as regiões da AWS**.

### Como criar a VPC e Subnets

Felizmente esse é um passo bem tranquilo a AWS já oferece um forma de automatizar isso bem simples.

