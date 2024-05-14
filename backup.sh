#!/bin/bash

clear

data=$(date +"%Y-%m-%d")

cor-vermelha='\033[0;31m'
cor-verde='\033[0;32m'
cor-padrao='\033[0m'

echo "Digite o caminho que você deseja criar um backup: "
read -r origem 

echo -e "\nDigite o caminho para o local onde você deseja guardar seu backup: "
read -r destino

# Adiciona a data ao destino do backup
destinoReformulado="$destino/Backup.$origem - $data"

# ======================================================================
# Verifica se os caminhos existem

if [ ! -d "$origem" ]; then
    echo -e "\n${cor-vermelha}Erro: O diretório de origem '$origem' não existe!${cor-padrao}"
    exit 1
fi

if [ ! -d "$destino" ]; then
    echo "\nCriando o diretório de destino '$destino'..."
    sudo mkdir -p "$destinoReformulado" 
fi

# ======================================================================
# Verifica se os caminhos existem

echo -e "\nIniciando o backup..." 
echo "("$origem") para ("$destinoReformulado")"
sudo rsync -a --delete "$origem/" "$destinoReformulado/"

# ======================================================================
# Verifica se o backup foi criado

if [ $? -eq 0 ]; then
    echo -e "\n${cor-verde}Backup Finalizado com sucesso!${cor-padrao}"
else
    echo -e "\n${cor-vermelha}Erro ao gerar o backup!${cor-padrao}"
fi

# ======================================================================
# Explicação

# (read -r origem) 			--> -r é usada para evitar que o comando interprete a barra (\) como um caracter de escape
# (mkdir -p "$destino") 	--> -p garante que todos os diretórios pai sejam criados
# (exit 1) 					--> Encerra o script
# (if [ $? -eq 0 ]; then) 	--> $? é uma variável especial que contém o status do último comando executado

# (rsync -a --delete "$origem/" "$destino/")
#
#  -a: Ativa o modo de cópia recursiva preservando permissões, timestamps, etc.
#
# --delete: Essa opção faz com que os arquivos no diretório de destino sejam excluídos 
#           se não existirem no diretório de origem durante a sincronização
