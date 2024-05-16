#!/bin/bash

data=$(date +"%Y-%m-%d")

cor_vermelha='\033[0;31m'
cor_verde='\033[0;32m'
cor_amarela='\033[33m'

cor_padrao='\033[0m'

# Informações do Sistema
infoSistema()
{

    clear

    echo -e "\nBuscando Informações...\n"

    # Informações da Distribuição
    # Versão do Sistema
    # Administrador da Máquina
    # Data da última Atualização

    source /etc/os-release
    distro="$PRETTY_NAME"
    kernel_version=$(uname -r)
    owner=$(whoami)
    last_update=$(stat -c "%y" /etc/passwd /etc/group /etc/shadow | sort -r | head -n 1 | awk '{print $1}')
    update_status=$(apt list --upgradable 2>/dev/null | wc -l)

    if [[ $update_status -gt 1 ]]; then
        system_update="${cor_vermelha}( Desatualizado )${cor_padrao}"
    else
        system_update="${cor_verde}( Atualizado )${cor_padrao}"
    fi

    echo -e "▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄\n"
    
    echo -e "${cor_amarela}[ ${cor_padrao}Distribuição Linux ${cor_amarela}]${cor_padrao} - $distro"
    echo -e "${cor_amarela}[ ${cor_padrao}Versão do Linux    ${cor_amarela}]${cor_padrao} - $kernel_version"
    echo -e "${cor_amarela}[ ${cor_padrao}Dono da máquina    ${cor_amarela}]${cor_padrao} - $owner"
    echo -e "${cor_amarela}[ ${cor_padrao}Última atualização ${cor_amarela}]${cor_padrao} - $last_update"
    echo -e "${cor_amarela}[ ${cor_padrao}Status da Máquina  ${cor_amarela}]${cor_padrao} - $system_update"
    
    echo -e "\n▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄\n"
}

# ======================================================================================================================

attSistema()
{
    clear

    echo -e "\nComo você gostaria de atualizar? ${cor_amarela}Atualização Basica ${cor_padrao}/ ${cor_amarela}Atualização Completa${cor_padrao} ?\n"
    echo -e "${cor_amarela}[ ${cor_padrao}/att  ${cor_amarela}]${cor_padrao} - Atualização Basica"
    echo -e "${cor_amarela}[ ${cor_padrao}/+att ${cor_amarela}]${cor_padrao} - Atualização Completa"
    echo -e "${cor_amarela}[ ${cor_padrao}/menu ${cor_amarela}]${cor_padrao} - Voltar Para o Menu Principal"
             
    echo -e "\n▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄\n"

    read -p "Escolha uma opção: " resposta

    case "$resposta" in
        "att") atualizarBasico ;;
        "+att") atualizacaoGeral ;;
        "menu") voltarMenu ;;
        *) echo -e "\nOpção Inválida...\n";;
    esac
}

# Função para Atualizar o Sistema
atualizarBasico()
{
    echo -e "\n\nExecultando uma Atualização Rapida...\n\n"

    # Atualização básica
    sudo apt update
    if [ $? -ne 0 ]; then
        echo -e "\n${cor_vemelha}Erro: Falha ao atualizar lista de pacotes!${cor_padrao}\n"
    fi

    sudo apt upgrade -y
    if [ $? -ne 0 ]; then
        echo -e "\n${cor_vemelha}Erro: Falha ao atualizar pacotes!${cor_padrao}\n"
    fi

    sudo apt autoremove -y
    if [ $? -ne 0 ]; then
        echo -e "\n${cor_vemelha}Erro: Falha ao remover pacotes desnecessários!${cor_padrao}\n"
    fi

    echo -e "\n\n${cor_verde}Atualização concluída!${cor_padrao}\n\n"
}

# Atualização Geral
atualizacaoGeral()
{
    echo -e "\n\nExecultando uma Atualização Completa...\n\n"

    # Atualização completa
    sudo apt update
    if [ $? -ne 0 ]; then
        echo -e "\n${cor_vemelha}Erro: Falha ao atualizar lista de pacotes!${cor_padrao}\n"
    fi

    sudo apt upgrade -y
    if [ $? -ne 0 ]; then
        echo -e "\n${cor_vemelha}Erro: Falha ao atualizar pacotes!${cor_padrao}\n"
    fi

    sudo apt dist-upgrade -y
    if [ $? -ne 0 ]; then
        echo -e "\n${cor_vemelha}Erro: Falha ao atualizar pacotes com dependências!${cor_padrao}\n"
    fi

    sudo apt autoremove -y
    if [ $? -ne 0 ]; then
        echo -e "\n${cor_vemelha}Erro: Falha ao remover pacotes desnecessários!${cor_padrao}\n"
    fi

    echo -e "\n\n${cor_verde}Atualização concluída!${cor_padrao}\n\n"
}


# ======================================================================================================================

# Função para verificar se o SSH está instalado
verificarSSH() 
{
    # Esta instalado?
    if dpkg -l | grep -q "openssh-server"; then
    
        # Esta em execução?
        if sudo systemctl is-active --quiet ssh; then
            echo -e "\n${cor_verde}O serviço SSH está instalado e em execução!${cor_padrao}\n"
            return 0
        else
            echo -e "\n${cor_amarela}O serviço SSH está instalado, mas não está em execução!${cor_padrao}\n"
            return 1
        fi
    else
        echo -e "\n${cor_vermelha}O serviço SSH não está instalado!${cor_padrao}\n"
        return 1
    fi
}

# Função para instalar o SSH
instalarSSH() 
{
    echo -e "\nPreparando pacotes de instalação...\n"
    sudo apt update -y

    echo -e "\n\nInstalando o serviço SSH...\n\n"
    sudo apt install openssh-server -y

    if [ $? -eq 0 ]; then
        echo -e "\n${cor_verde}SSH instalado com sucesso!${cor_padrao}\n"
    else
        echo -e "\n${cor_vermelha}Erro ao instalar o SSH!${cor_padrao}\n"
        return 1
    fi
}

# Configurar a porta
configurarPortaSSH() 
{
    echo -e "\nConfigurando a porta SSH...\n"
    read -p "Digite a porta desejada para SSH: " porta_ssh
    sudo sed -i "s/#Port 22/Port $porta_ssh/g" /etc/ssh/sshd_config
    sudo systemctl restart ssh
    echo -e "\n${cor_verde}Porta SSH configurada para $porta_ssh. Certifique-se de liberar a porta no firewall, se necessário!${cor_padrao}"
}

# Função para configurar a autenticação por senha
configurarSenhaSSH() 
{
    echo -e "\nConfigurando autenticação por senha para o SSH...\n"
    read -s -p "Digite a nova senha para autenticação SSH: " senha_ssh
    echo -e "root:$senha_ssh" | sudo chpasswd
    sudo systemctl restart ssh
    echo -e "\n${cor_verde}Autenticação por senha configurada para o SSH!${cor_padrao}\n"
}

# Função para configurar o SSH
configurarSSH() 
{
    instalarSSH || return 1
    configurarPortaSSH
    configurarSenhaSSH
}

# Função principal
sshMenu() 
{
    clear
    configurarSSH || return 1

    # Comando SSH para Windows
    echo -e "No Windows, você pode se conectar usando o seguinte comando no Prompt de Comando (CMD):"
    echo -e "${cor_amarela}ssh <nome_do_usuario>@<endereço_IP> -p <porta_ssh>${cor_padrao}\n"

    # Comando SSH para Linux
    echo -e "No Linux, você pode se conectar usando o seguinte comando no terminal:"
    echo -e "${cor_amarela}ssh <nome_do_usuario>@<endereço_IP> -p <porta_ssh>${cor_padrao}\n"
}

# ======================================================================================================================

# Função para configurar o serviço de proxy
proxyMenu()
{
    clear
    echo -e "\nPreparando para configurar o Proxy...\n"
    echo "Digite o endereço do proxy: "
    read -r proxy_address
    echo "Digite a porta do proxy: "
    read -r proxy_port

    # Configurar o proxy
    export http_proxy="$proxy_address:$proxy_port"
    export https_proxy="$proxy_address:$proxy_port"
    export ftp_proxy="$proxy_address:$proxy_port"

    # Verifica se houve algum erro!
    if [ $? -eq 0 ]; then
        echo -e "\n${cor_verde}Proxy configurado com sucesso!${cor_padrao}\n"
    else
        echo -e "\n${cor_vemelha}Erro ao configurar o proxy!${cor_padrao}\n"
    fi
}


# ======================================================================================================================

# Função para exibir informações de rede
redeMenu()
{
    echo "\nExibindo informações de rede...\n"

    # Exibe informações de interface de rede
    sudo ip -c -br a

    # Exibe informações da tabela ARP
    echo -e "\nExibindo a tabela ARP...\n"
    arp -a
}


# ======================================================================================================================

# Função para gerenciar arquivos
fileMenu()
{
    clear

    echo -e "\n${cor_amarelo}[ ${cor_padrao}/tar  ${cor_amarelo}]${cor_padrao} - Empacotar Pasta de Arquivos"
    echo -e "\n${cor_amarelo}[ ${cor_padrao}/-tar ${cor_amarelo}]${cor_padrao} - Desempacotar Pasta de Arquivos"
    echo -e "\n${cor_amarelo}[ ${cor_padrao}/menu ${cor_amarelo}]${cor_padrao} - Voltar Para o Menu Principal"


    read -p "Escolha uma opção: " opcao

    case $opcao in
        "/tar")
            empacotar
            ;;
        "/-tar")
            desempacotar
            ;;
        "/menu")
            voltarMenu
            ;;
        *)
            echo -e "\nOpção inválida...\n"
            ;;
    esac
}

empacotar()
{
    clear
    echo "### Empacotar Pasta de Arquivos ###"
    read -p "Digite o caminho completo da pasta que deseja empacotar: " caminho_origem
    if [ ! -d "$caminho_origem" ]; then
        echo -e "${cor_vemelha}Erro: O caminho especificado não corresponde a uma pasta válida!${cor_padrao}"
    fi

    read -p "Digite o nome do arquivo de destino para o pacote (com extensão .tar ou .tar.gz): " nome_arquivo
    if [[ ! "$nome_arquivo" =~ \.tar(\.gz)?$ ]]; then
        echo -e "${cor_vemelha}Erro: O nome do arquivo de destino deve ter a extensão .tar ou .tar.gz!${cor_padrao}"
    fi

    tar -czf "$nome_arquivo" -C "$(dirname "$caminho_origem")" "$(basename "$caminho_origem")"
    if [ $? -eq 0 ]; then
        echo -e "\n${cor_verde}Pasta empacotada com sucesso em $nome_arquivo!${cor_padrao}\n"
    else
        echo -e "\n${cor_vemelha}Erro ao empacotar a pasta!${cor_padrao}\n"
    fi
}

desempacotar()
{
    clear

    echo "### Desempacotar Pasta de Arquivos ###"
    read -p "Digite o caminho completo do arquivo compactado que deseja desempacotar: " caminho_origem
    if [ ! -f "$caminho_origem" ]; then
        echo -e "\n${cor_vemelha}Erro: O arquivo compactado não existe!${cor_padrao}\n"
    fi

    read -p "Digite o caminho completo do destino para desempacotar o arquivo: " caminho_destino
    if [ ! -d "$caminho_destino" ]; then
        echo -e "\n${cor_vemelha}Erro: O caminho de destino não corresponde a uma pasta válida!${cor_padrao}\n"
    fi

    tar -xzf "$caminho_origem" -C "$caminho_destino"
    if [ $? -eq 0 ]; then
        echo -e "\n${cor_verde}Arquivo desempacotado com sucesso em $caminho_destino!${cor_padrao}\n"
    else
        echo -e "\n${cor_vemelha}Erro ao desempacotar o arquivo!${cor_padrao}\n"
    fi
}

# ======================================================================================================================

# Função para criar backups
backupScript()
{
    clear

    echo -e "\n[ Exemplo: /home/user ] Digite o caminho que você deseja criar um backup: "
    read -r origem

    echo -e "\n[ Exemplo: /var/backups ] Digite o caminho para o local onde você deseja guardar seu backup: "
    read -r destino

    # Adiciona a data ao destino do backup
    destinoReformulado="$destino/BACKUP.$(basename $origem) - $data"

    # ======================================================================
    # Verifica se os caminhos existem

    if [ ! -d "$origem" ]; then
        echo -e "\n${cor_vermelha}Erro: O diretório de origem '$origem' não existe!${cor_padrao}"
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
        echo -e "\n${cor_verde}Backup Finalizado com sucesso!${cor_padrao}\n"
    else
        echo -e "\n${cor_vermelha}Erro ao gerar o backup!${cor_padrao}\n"
    fi

}

# ======================================================================================================================

# Função para exibir informações sobre o script
sobreScript()
{
    echo -e "\nSobre o script...\n"
}

sair()
{

    echo -e "\nVocê Deseja Realmente sair?"
    echo -e "\n[ ${cor_amarela}Sim ${cor_padrao}ou ${cor_amarela}Não ${cor_padrao}]\n"
    
    read -p ":" resposta
    resposta=$(echo "$resposta" | tr '[:upper:]' '[:lower:]')

    case $resposta in
        "s" | "sim") 
            echo -e "\nSaindo da aplicação...\n"
            exit 0
            ;;
        "n" | "nao") 
            voltarMenu 
            ;;
        *) 
            echo -e "\nOpção Inválida...\n" 
            ;;
    esac

}

voltarMenu()
{
    clear
}

# ======================================================================================================================

# MENU DO SCRIPT
mostrarMenu()
{

    clear

    cat << EOF 


    ▄█     █▄      ▄████████        ▄████████  ▄██   ▄       ▄████████       ███        ▄████████    ▄▄▄▄███▄▄▄▄
   ███     ███    ███    ███       ███    ███  ███   ██▄    ███    ███  ▀█████████▄    ███    ███  ▄██▀▀▀███▀▀▀██▄
   ███     ███    ███    █▀        ███    █▀   ███▄▄▄███    ███    █▀       ▀███▀▀██   ███    █▀   ███   ███   ███
   ███     ███    ███              ███         ▀▀▀▀▀▀███    ███              ███   ▀  ▄███▄▄▄      ███   ███   ███
   ███     ███  ▀███████████     ▀███████████  ▄██   ███  ▀███████████       ███     ▀▀███▀▀▀      ███   ███   ███
   ███     ███           ███              ███  ███   ███           ███       ███       ███   █▄    ███   ███   ███
   ███ ▄█▄ ███     ▄█    ███        ▄█    ███  ███   ███     ▄█    ███       ███       ███   ███   ███   ███   ███
    ▀███▀███▀    ▄████████▀  ██   ▄████████▀    ▀█████▀    ▄████████▀      ▄████▀     ██████████    ▀█   ███   █▀

▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄

      ---------------------- [ @Gabriel.Strider || Menu de Interações || WS.System V1.0 ] ----------------------

                                    [ /info   ]   [[ Informações do Sistema   ]]
                                    [ /att    ]   [[ Atualizar Sistema        ]]
                                    [ /ssh    ]   [[ Serviço de SSH           ]]
                                    [ /proxy  ]   [[ Serviço de Proxy         ]]
                                    [ /rede   ]   [[ Informações de Rede      ]]
                                    [ /file   ]   [[ Empacotar / Desempacotar ]]
                                    [ /save   ]   [[ Criar um Backup          ]]
                                    [ /sobre  ]   [[ Sobre                    ]]
                                    [ /sair   ]   [[ Sair                     ]]

▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄

EOF
}

while true; do

    mostrarMenu

    read -p "Escolha uma opção: /" menu
    menu=$(echo "$menu" | tr '[:upper:]' '[:lower:]')

    case $menu in
        "info") infoSistema ;;
        "att") attSistema ;;
        "ssh") sshMenu ;;
        "proxy") proxyMenu ;;
        "rede") redeMenu ;;
        "file") fileMenu ;;
        "save") backupScript ;;
        "sobre") sobreScript ;;
        "sair") sair ;;
        *) echo -e "\nOpção Inválida...\n" ;;
    esac

read -n 1 -s -r -p "Pressione qualquer tecla para continuar..."
done
