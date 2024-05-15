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

    echo -e "${cor_amarela}[ ${cor_padrao}Distribuição Linux ${cor_amarela}]${cor_padrao} - $distro"
    echo -e "${cor_amarela}[ ${cor_padrao}Versão do Linux    ${cor_amarela}]${cor_padrao} - $kernel_version"
    echo -e "${cor_amarela}[ ${cor_padrao}Dono da máquina    ${cor_amarela}]${cor_padrao} - $owner"
    echo -e "${cor_amarela}[ ${cor_padrao}Última atualização ${cor_amarela}]${cor_padrao} - $last_update"
    echo -e "${cor_amarela}[ ${cor_padrao}Status da Máquina  ${cor_amarela}]${cor_padrao} - $system_update\n"

}

# ======================================================================================================================

attSistema()
{
    clear

    echo -e "\nVocê deseja atualizar apenas o necessário ou uma atualização geral?\n"
    echo -e "${cor_amarela}[  ${cor_padrao}/att   ${cor_amarela}]${cor_padrao} - Atualizar Apenas o Necessário"
    echo -e "${cor_amarela}[  ${cor_padrao}/+att  ${cor_amarela}]${cor_padrao} - Atualizar o Sistema Geral"
    echo -e "${cor_amarela}[  ${cor_padrao}/menu  ${cor_amarela}]${cor_padrao} - Voltar Para o Menu Principal\n"

    read -p "Escolha uma opção: " resposta

    case "$resposta" in
        "att") atualizarBasico ;;
        "+att") atualizacaoGeral ;;
        "/") mostrarMenu ;;
        *) echo -e "Opção Inválida...";;
    esac
}

# Função para Atualizar o Sistema
atualizarBasico()
{
    echo ""
    echo -e "\nAtualizando o sistema...\n"

    # Atualização básica
    sudo apt update
    if [ $? -ne 0 ]; then
        echo "\n${cor_vemelha}Erro: Falha ao atualizar lista de pacotes!${cor_padrao}\n"
        read -n 1 -s -r -p "Pressione qualquer tecla para continuar..."
        echo ""
        mostrarMenu
    fi

    sudo apt upgrade -y
    if [ $? -ne 0 ]; then
        echo "\n${cor_vemelha}Erro: Falha ao atualizar pacotes!${cor_padrao}\n"
        read -n 1 -s -r -p "Pressione qualquer tecla para continuar..."
        echo ""
        mostrarMenu
    fi

    sudo apt autoremove -y
    if [ $? -ne 0 ]; then
        echo "\n${cor_vemelha}Erro: Falha ao remover pacotes desnecessários!${cor_padrao}\n"
        read -n 1 -s -r -p "Pressione qualquer tecla para continuar..."
        echo ""
        mostrarMenu
    fi

}

# Atualização Geral
atualizacaoGeral()
{
    echo -e "\nAtualizando o sistema...\n"

    # Atualização completa
    sudo apt update
    if [ $? -ne 0 ]; then
        echo +e "\n${cor_vemelha}Erro: Falha ao atualizar lista de pacotes!${cor_padrao}\n"
        read -n 1 -s -r -p "Pressione qualquer tecla para continuar..."
        echo ""
        mostrarMenu
    fi

    sudo apt upgrade -y
    if [ $? -ne 0 ]; then
        echo -e "\n${cor_vemelha}Erro: Falha ao atualizar pacotes!${cor_padrao}\n"
        read -n 1 -s -r -p "Pressione qualquer tecla para continuar..."
        echo ""
        mostrarMenu
    fi

    sudo apt dist-upgrade -y
    if [ $? -ne 0 ]; then
        echo -e "\n${cor_vemelha}Erro: Falha ao atualizar pacotes com dependências!${cor_padrao}\n"
        read -n 1 -s -r -p "Pressione qualquer tecla para continuar..."
        echo ""
        mostrarMenu
    fi

    sudo apt autoremove -y
    if [ $? -ne 0 ]; then
        echo -e "\n${cor_vemelha}Erro: Falha ao remover pacotes desnecessários!${cor_padrao}\n"
        read -n 1 -s -r -p "Pressione qualquer tecla para continuar..."
        echo ""
        mostrarMenu
    fi

    echo -e "\n${cor_verde}Atualização concluída!${cor_padrao}\n"
    read -n 1 -s -r -p "Pressione qualquer tecla para continuar..."
    echo ""
    mostrarMenu
}


# ======================================================================================================================

# Função para configurar o serviço SSH
sshMenu()
{
    clear

    # Verifica qual o tipo de sistema
    linux_system=$(lsb_release -si | tr '[:upper:]' '[:lower:]')

    echo -e "\nIniciando o Serviço do SSH...\n"

    # Se o Sistema for Ubuntu ou Debian
    if [ "$linux_system" == "ubuntu" ] || [ "$linux_system" == "debian" ]; then
        sudo systemctl start ssh
        if [ $? -eq 0 ]; then
            sudo systemctl status ssh
            read -n 1 -s -r -p "Pressione qualquer tecla para continuar..."
            echo ""
            mostrarMenu
        else
            echo -e "\n${cor_vemelha}Erro: Falha ao iniciar o serviço SSH!${cor_padrao}\n"
            read -n 1 -s -r -p "Pressione qualquer tecla para continuar..."
            echo ""
            mostrarMenu
        fi

    # Se o Sistema for CentOS
    elif [ "$linux_system" == "centos" ]; then
        sudo service ssh start
        if [ $? -eq 0 ]; then
            sudo service ssh status
            read -n 1 -s -r -p "Pressione qualquer tecla para continuar..."
            echo ""
            mostrarMenu
        else
            echo -e "\n${cor_vemelha}Erro: Falha ao iniciar o serviço SSH!${cor_padrao}\n"
            read -n 1 -s -r -p "Pressione qualquer tecla para continuar..."
            echo ""
            mostrarMenu
        fi

    else
        echo -e "${cor_vemelha}Serviço SSH Não Instalado ou Não Configurado Corretamente...${cor_padrao}"
        echo " "
        read -n 1 -s -r -p "Pressione qualquer tecla para continuar..."
        echo ""
        mostrarMenu
    fi
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
        read -n 1 -s -r -p "Pressione qualquer tecla para continuar..."
        echo ""
        mostrarMenu
    else
        echo -e "\n${cor_vemelha}Erro ao configurar o proxy!${cor_padrao}\n"
        read -n 1 -s -r -p "Pressione qualquer tecla para continuar..."
        echo ""
        mostrarMenu
    fi
}


# ======================================================================================================================

# Função para exibir informações de rede
redeMenu()
{
    echo "\nExibindo informações de rede...\n"

    # Exibe informações de interface de rede
    sudo ip -c -br a

    # Verifica se houve algum erro
    if [ $? -eq 0 ]; then
        echo ""
        read -n 1 -s -r -p "Pressione qualquer tecla para continuar..."
        echo ""
        mostrarMenu
    else
        echo -e "\n${cor_vemelha}Erro ao exibir informações de rede!${cor_padrao}\n"
        read -n 1 -s -r -p "Pressione qualquer tecla para continuar..."
        echo ""
        mostrarMenu
    fi

    # Exibe informações da tabela ARP
    echo -e "\nExibindo a tabela ARP...\n"
    arp -a

    # Verifica se houve algum erro durante a execução do comando arp
    if [ $? -eq 0 ]; then
        echo ""
        read -n 1 -s -r -p "Pressione qualquer tecla para continuar..."
        echo ""
        mostrarMenu
    else
        echo -e "\n${cor_vemelha}Erro ao exibir tabela ARP.${cor_padrao}\n"
        read -n 1 -s -r -p "Pressione qualquer tecla para continuar..."
        echo ""
        mostrarMenu
    fi
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
            mostrarMenu
            ;;
        *)
            echo "Opção inválida."
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
        read -n 1 -s -r -p "Pressione qualquer tecla para continuar..."
        echo ""
        mostrarMenu
    fi

    read -p "Digite o nome do arquivo de destino para o pacote (com extensão .tar ou .tar.gz): " nome_arquivo
    if [[ ! "$nome_arquivo" =~ \.tar(\.gz)?$ ]]; then
        echo -e "${cor_vemelha}Erro: O nome do arquivo de destino deve ter a extensão .tar ou .tar.gz!${cor_padrao}"
        read -n 1 -s -r -p "Pressione qualquer tecla para continuar..."
        echo ""
        mostrarMenu
    fi

    tar -czf "$nome_arquivo" -C "$(dirname "$caminho_origem")" "$(basename "$caminho_origem")"
    if [ $? -eq 0 ]; then
        echo -e "\n${cor_verde}Pasta empacotada com sucesso em $nome_arquivo!${cor_padrao}\n"
        read -n 1 -s -r -p "Pressione qualquer tecla para continuar..."
        echo ""
        mostrarMenu
    else
        echo -e "\n${cor_vemelha}Erro ao empacotar a pasta!${cor_padrao}\n"
        read -n 1 -s -r -p "Pressione qualquer tecla para continuar..."
        echo ""
        mostrarMenu
    fi
}

desempacotar()
{
    clear

    echo "### Desempacotar Pasta de Arquivos ###"
    read -p "Digite o caminho completo do arquivo compactado que deseja desempacotar: " caminho_origem
    if [ ! -f "$caminho_origem" ]; then
        echo -e "\n${cor_vemelha}Erro: O arquivo compactado não existe!${cor_padrao}\n"
        read -n 1 -s -r -p "Pressione qualquer tecla para continuar..."
        echo ""
        mostrarMenu
    fi

    read -p "Digite o caminho completo do destino para desempacotar o arquivo: " caminho_destino
    if [ ! -d "$caminho_destino" ]; then
        echo -e "\n${cor_vemelha}Erro: O caminho de destino não corresponde a uma pasta válida!${cor_padrao}\n"
        read -n 1 -s -r -p "Pressione qualquer tecla para continuar..."
        echo ""
        mostrarMenu
    fi

    tar -xzf "$caminho_origem" -C "$caminho_destino"
    if [ $? -eq 0 ]; then
        echo -e "\n${cor_verde}Arquivo desempacotado com sucesso em $caminho_destino!${cor_padrao}\n"
        read -n 1 -s -r -p "Pressione qualquer tecla para continuar..."
        echo ""
        mostrarMenu
    else
        echo -e "\n${cor_vemelha}Erro ao desempacotar o arquivo!${cor_padrao}\n"
        read -n 1 -s -r -p "Pressione qualquer tecla para continuar..."
        echo ""
        mostrarMenu
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
        read -n 1 -s -r -p "Pressione qualquer tecla para continuar..."
        echo ""
        mostrarMenu
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
        read -n 1 -s -r -p "Pressione qualquer tecla para continuar..."
        echo ""
        mostrarMenu
    else
        echo -e "\n${cor_vermelha}Erro ao gerar o backup!${cor_padrao}\n"
        read -n 1 -s -r -p "Pressione qualquer tecla para continuar..."
        echo ""
        mostrarMenu
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
    echo -e "${cor_amarela}[ ${cor_padrao}S ${cor_amarela}/${cor_padrao} N ${cor_amarela}]${cor_padrao} - ${cor_amarela}[[${cor_padrao} Sim ${cor_amarela}ou${cor_padrao} Não ${cor_amarela}]]${cor_padrao}\n"
    
    read -p " " resposta
    resposta=$(echo "$resposta" | tr '[:upper:]' '[:lower:]')

    case $resposta in
        "s") 
            echo "Saindo da aplicação..."
            exit 0
            ;;
        "n") 
            mostrarMenu 
            ;;
        *) 
            echo "Opção Inválida..." 
            ;;
    esac
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

                                     [  /info   ]   [[  Informações do Sistema    ]]
                                     [  /att    ]   [[  Atualizar Sistema         ]]
                                     [  /ssh    ]   [[  Serviço de SSH            ]]
                                     [  /proxy  ]   [[  Serviço de Proxy          ]]
                                     [  /rede   ]   [[  Informações de Rede       ]]
                                     [  /file   ]   [[  Empacotar / Desempacotar  ]]
                                     [  /save   ]   [[  Criar um Backup           ]]
                                     [  /sobre  ]   [[  Sobre                     ]]
                                     [  /exit   ]   [[  Sair                      ]]

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
        *) echo "Opção Inválida..." ;;
    esac

read -n 1 -s -r -p "Pressione qualquer tecla para continuar..."
done
