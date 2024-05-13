#!/bin/bash

# \e[31m - Vemelho
# \e[32m - Verde
# \e[0m  - Padrão

# Informações do Sistema
infoSistema()
{
    clear

    # Verifica se o comando lsb_release está disponível
    if ! command -v lsb_release &> /dev/null; then
        echo -e "\e[31mErro: Comando 'lsb_release' não encontrado!\e[0m"
        return 1
    fi

    # Verifica se o comando apt está disponível
    if ! command -v apt &> /dev/null; then
        echo -e "\e[31mErro: Comando 'apt' não encontrado!\e[0m"
        return 1
    fi

    # Informações da Distribuição
    # Versão do Sistema
    # Administrador da Máquina
    # Data da última Atualização
    distro=$(lsb_release -d | awk -F ":" '{print $2}' | tr -d '[:space:]')
    kernel_version=$(uname -r)
    owner=$(whoami)
    last_update=$(stat -c "%y" /etc/passwd /etc/group /etc/shadow | sort -r | head -n 1 | awk '{print $1}')

    # Sistema está Atualizado?
    sudo apt update > /dev/null 2>&1
    if [ $? -ne 0 ]; then
        echo -e "\e[31mErro: Falha ao atualizar lista de pacotes!\e[0m" >&2
        return 1
    fi

    update_status=$(apt list --upgradable 2>/dev/null | wc -l)

    if [[ $update_status -gt 1 ]]; then
        system_update="( Desatualizado )"
        color="\e[31m"
    else
        system_update="( Atualizado )"
        color="\e[32m"
    fi

    echo -e "[ Distribuição Linux ] - $distro"
    echo -e "[ Versão do Linux    ] - $kernel_version"
    echo -e "[ Dono da máquina    ] - $owner"
    echo -e "[ Última atualização ] - $last_update"
    echo -e "[ Status da Máquina  ] - ${color}$system_update\e[0m"
    echo " "
    read -p "Pressione Enter para continuar..."
}

# ======================================================================================================================

attSistema() 
{
    clear
    
    cat << "EOF"
    ▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄

    Você deseja atualizar apenas o necessário ou uma atualização geral?
    [ /att  ] Atualizar Apenas o Necessário
    [ /+att ] Atualizar o Sistema Geral
    [ /menu ] Voltar Para o Menu Principal

    ▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄
    
EOF

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
    echo "Atualizando o sistema..."

    # Atualização básica
    sudo apt update
    if [ $? -ne 0 ]; then
        echo "\e[31mErro: Falha ao atualizar lista de pacotes!\e[0m"
        return 1
    fi

    sudo apt upgrade -y
    if [ $? -ne 0 ]; then
        echo "\e[31mErro: Falha ao atualizar pacotes!\e[0m"
        return 1
    fi

    sudo apt autoremove -y
    if [ $? -ne 0 ]; then
        echo "\e[31mErro: Falha ao remover pacotes desnecessários!\e[0m"
        return 1
    fi

    echo -e "\e[32mAtualização concluída!\e[0m"
}

# Atualização Geral
atualizacaoGeral()
{
    echo ""
    echo "Atualizando o sistema..."

    # Atualização completa
    sudo apt update
    if [ $? -ne 0 ]; then
        echo +e "\e[31mErro: Falha ao atualizar lista de pacotes!\e[0m"
        return 1
    fi

    sudo apt upgrade -y
    if [ $? -ne 0 ]; then
        echo -e "\e[31mErro: Falha ao atualizar pacotes!\e[0m"
        return 1
    fi

    sudo apt dist-upgrade -y
    if [ $? -ne 0 ]; then
        echo -e "\e[31mErro: Falha ao atualizar pacotes com dependências!\e[0m"
        return 1
    fi

    sudo apt autoremove -y
    if [ $? -ne 0 ]; then
        echo -e "\e[31mErro: Falha ao remover pacotes desnecessários!\e[0m"
        return 1
    fi

    echo -e "\e[32mAtualização concluída!\e[0m"
}


# ======================================================================================================================

# Função para configurar o serviço SSH
sshMenu() 
{
    clear

    # Verifica qual o tipo de sistema
    linux_system=$(lsb_release -si | tr '[:upper:]' '[:lower:]')

    echo "Iniciando o Serviço do SSH..."

    # Se o Sistema for Ubuntu ou Debian
    if [ "$linux_system" == "ubuntu" ] || [ "$linux_system" == "debian" ]; then
        sudo systemctl start ssh
        if [ $? -eq 0 ]; then
            echo -e "\e[32mServiço SSH Iniciado e Pronto para Uso!\e[0m"
        else
            echo -e "\e[31mErro: Falha ao iniciar o serviço SSH!\e[0m"
        fi
        sudo systemctl status ssh
        echo " "
        read -p "Pressione Enter para continuar..."

    # Se o Sistema for CentOS
    elif [ "$linux_system" == "centos" ]; then
        sudo service ssh start
        if [ $? -eq 0 ]; then
            echo -e "\e[32mServiço SSH Iniciado e Pronto para Uso!\e[0m"
        else
            echo -e "\e[31mErro: Falha ao iniciar o serviço SSH!\e[0m"
        fi

        sudo service ssh status
        echo " "
        read -p "Pressione Enter para continuar..."

    else
        echo -e "\e[31mServiço SSH Não Instalado ou Não Configurado Corretamente...\e[0m"
        echo " "
        read -p "Pressione Enter para continuar..."

    fi
}

# ======================================================================================================================

# Função para configurar o serviço de proxy
proxyMenu() 
{
    clear
    echo "Preparando para configurar o Proxy..."
    echo ""
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
        echo -e "\e[32mProxy configurado com sucesso!\e[0m"
    else
        echo -e "\e[31mErro ao configurar o proxy!\e[0m"
    fi
}


# ======================================================================================================================

# Função para exibir informações de rede
redeMenu() 
{
    echo "Exibindo informações de rede..."
    echo ""
    
    # Exibe informações de interface de rede
    sudo ip -c -br a

    # Verifica se houve algum erro
    if [ $? -eq 0 ]; then
        echo -e "\e[32mInformações de rede exibidas!\e[0m"
    else
        echo -e "\e[31mErro ao exibir informações de rede!\e[0m"
        return 1
    fi

    # Exibe informações da tabela ARP
    echo "Exibindo a tabela ARP..."
    arp -a

    # Verifica se houve algum erro durante a execução do comando arp
    if [ $? -eq 0 ]; then
        echo -e "\e[32mTabela ARP exibida com sucesso!\e[0m"
    else
        echo -e "\e[31mErro ao exibir tabela ARP.\e[0m"
        return 1
    fi
}


# ======================================================================================================================

# Função para gerenciar arquivos
fileMenu() 
{
    clear

    cat << "EOF"

    ▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄

    [ /tar  ] Empacotar Pasta de Arquivos
    [ /-tar ] Desempacotar Pasta de Arquivos
    [ /menu ] Voltar Para o Menu Principal

    ▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄

EOF

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
        echo -e "\e[31mErro: O caminho especificado não corresponde a uma pasta válida!\e[0m"
        return 1
    fi

    read -p "Digite o nome do arquivo de destino para o pacote (com extensão .tar ou .tar.gz): " nome_arquivo
    if [[ ! "$nome_arquivo" =~ \.tar(\.gz)?$ ]]; then
        echo -e "\e[31mErro: O nome do arquivo de destino deve ter a extensão .tar ou .tar.gz!\e[0m"
        return 1
    fi

    tar -czf "$nome_arquivo" -C "$(dirname "$caminho_origem")" "$(basename "$caminho_origem")"
    if [ $? -eq 0 ]; then
        echo -e "\e[32mPasta empacotada com sucesso em $nome_arquivo!\e[0m"
    else
        echo -e "\e[31mErro ao empacotar a pasta!\e[0m"
    fi
}

desempacotar() 
{
    clear
    echo "### Desempacotar Pasta de Arquivos ###"
    read -p "Digite o caminho completo do arquivo compactado que deseja desempacotar: " caminho_origem
    if [ ! -f "$caminho_origem" ]; then
        echo -e "\e[31mErro: O arquivo compactado não existe!\e[0m"
        return 1
    fi

    read -p "Digite o caminho completo do destino para desempacotar o arquivo: " caminho_destino
    if [ ! -d "$caminho_destino" ]; then
        echo -e "\e[31mErro: O caminho de destino não corresponde a uma pasta válida!\e[0m"
        return 1
    fi

    tar -xzf "$caminho_origem" -C "$caminho_destino"
    if [ $? -eq 0 ]; then
        echo -e "\e[32mArquivo desempacotado com sucesso em $caminho_destino!\e[0m"
    else
        echo -e "\e[31mErro ao desempacotar o arquivo!\e[0m"
    fi
}

# ======================================================================================================================

# Função para exibir a ajuda
helpScript()
{
    echo "Exibindo ajuda..."
    echo " "
    read -p "Pressione Enter para continuar..."
}

# ======================================================================================================================

# Função para exibir informações sobre o script
sobreScript()
{
    echo "Sobre o script..."
}

sair() 
{
    cat << "EOF"

    ▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄

    Você Deseja Realmente sair?
    [ S / N ] - [[ Sim ou Não ]]

    ▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄

EOF

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

    cat << "EOF"

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

                                    [ /info  ]  [[ Informações do Sistema   ]]
                                    [ /att   ]  [[ Atualizar Sistema        ]]
                                    [ /ssh   ]  [[ Serviço de SSH           ]]
                                    [ /proxy ]  [[ Serviço de Proxy         ]]
                                    [ /rede  ]  [[ Informações de Rede      ]]
                                    [ /file  ]  [[ Empacotar / Desempacotar ]]
                                    [ /help  ]  [[ Ajuda                    ]]
                                    [ /sobre ]  [[ Sobre                    ]]
                                    [ /exit  ]  [[ Sair                     ]]

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
        "help") helpScript ;;
        "sobre") sobreScript ;;
        "sair") sair ;;
        *) echo "Opção Inválida..." ;;
    esac

read -p "Pressione Enter para continuar..."
done
