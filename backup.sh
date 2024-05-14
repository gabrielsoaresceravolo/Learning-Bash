#!/bin/bash

echo "Digite o caminho que você deseja criar o backup: "
read -r origem 

data=$(date +"%Y-%m-%d")

destino="/backup/backup_$data"

# ======================================================================
# Verifica se os caminhos existem

if [ ! -d "$origem" ]; then
    echo "Erro: O diretório de origem '$origem' não existe."
    exit 1
fi

if [ ! -d "$destino" ]; then
    echo "Criando o diretório de destino '$destino'..."
    sudo mkdir -p "$destino" 
fi

# ======================================================================
# Verifica se os caminhos existem

echo "Iniciando o backup..." 
echo "("$origem") para ("$destino")"
sudo rsync -av --delete "$origem/" "$destino/"

# ======================================================================
# Verifica se o backup foi criado

if [ $? -eq 0 ]; then
    echo "Backup Finalizado"
else
    echo "Erro ao execultar o backup"
fi

# ======================================================================
# Explicação

# (read -r origem) 			--> -r é usada para evitar que o comando interprete a barra (\) como um caracter de escape
# (mkdir -p "$destino") 	--> -p garante que todos os diretórios pai sejam criados
# (exit 1) 					--> Encerra o script
# (if [ $? -eq 0 ]; then) 	--> $? é uma variável especial que contém o status do último comando executado



# (rsync -av --delete "$origem/" "$destino/")
#
#  -a: Ativa o modo de cópia recursiva preservando permissões, timestamps, etc.
#  -v: Ativa a saída detalhada, mostrando quais arquivos estão sendo copiados
#
# --delete: Essa opção faz com que os arquivos no diretório de destino sejam excluídos 
#           se não existirem no diretório de origem durante a sincronização
