#!/bin/bash

TZDATA1=$(rpm -qa |grep tzdata-2) #Coletando a versão do tzdata do sistema
TZDATA2=$(rpm -qa |grep tzdata-java) #Coletando a versão do java do tzdata
TZDATAPENELOPE=$(/opt/jre1.8.0_25/bin/java -jar /tmp/tzupdater.jar -V |grep JRE) #Coletando a versão do tzdata da penelope

#Verifica se a versão do tzdata do sistema do java é a mais recente, se for ele pula o processo, caso contrário, inicia o processo de atualização. 
if [[ $TZDATA1 == "tzdata-2020d-1.el6.noarch" && $TZDATA2 == "tzdata-java-2020d-1.el6.noarch" ]]
then
    
    tput setaf 2; echo "Tzdata do TC já está atualizado!"; tput sgr0

else

    tput setaf 2; echo "Tzdata do TC já está atualizado! Iniciando os processos."; tput sgr0

    tput setaf 2; echo 'Desabilitando verificação de SSL do yum.conf...'; tput sgr0
    echo "sslverify=false" >> /etc/yum.conf #desativação necessária, pois por conta da versão atual do centos não existem mais repositórios oficiais da RedHat e por conta disso retornava erro com o SSL ativo.

    #Verifica se existem os arquivos de atualização no sistema, se tiver pula o processo de download, caso contrário, faz o download. 
    if [[ -f tzdata-2020d-1.el6.noarch && -f tzdata-java-2020d-1.el6.noarch ]]
    then

        tput setaf 2; echo "O arquivo de atualização já existe no sistema, pulando etapa de download."; tput sgr0

    else

        tput setaf 2; echo 'Baixando arquivos necessários...'; tput sgr0
        wget github.com/JoaoPedro-Ribeiro/updatetzdata/raw/main/tzdata-2020d-1.el6.noarch.rpm
        wget github.com/JoaoPedro-Ribeiro/updatetzdata/raw/main/tzdata-java-2020d-1.el6.noarch.rpm

    fi

    tput setaf 2; echo 'Instalando atualizações...'; tput sgr0
    yum update tzdata-2020d-1.el6.noarch.rpm -y
    yum update tzdata-java-2020d-1.el6.noarch.rpm -y
   
    tput setaf 2; echo 'Verificando a hora...'; tput sgr0
    hwclock -w
    date
    hwclock

    tput setaf 2; echo 'Confira a versão atual para validar a atualização...'; tput sgr0
    rpm -qa |grep tzdata

    VERIFICACAOSISTEMA=$(rpm -qa |grep tzdata) #Coleta qual a versão atual do tzdata do TC

    if [[ $VERIFICACAOSISTEMA =~ "tzdata-2020" ]]; 
    then

        tput setaf 2; echo "Atualização do sistema realizada com sucesso!"; tput sgr0
    
    else

        tput setaf 1; echo "Atualização do sistema falhou!"; tput sgr0
    fi

fi

#Verifica qual a versão do tzdata da penelope que foi inserido na variavel, se for a 2021 pula o processo, caso contrário, inicia a atualização.
if [[ $TZDATAPENELOPE =~ "tzdata2021" ]]; 
then

   tput setaf 2; echo "Tzdata da Penelope já está atualizado!"; tput sgr0

else

    tput setaf 2; echo "Tzdata da Penelope já está atualizado! Iniciando os processos."; tput sgr0

    #Verifica se existem os arquivos de atualização no sistema, se tiver pula o processo de download, caso contrário, faz o download. 
    if [[ -f "/tmp/tzupdater.jar" ]]
    then

        tput setaf 2; echo "O arquivo de atualização já existe no sistema, pulando etapa de download."; tput sgr0
    
    else

        tput setaf 2; echo 'O arquivo de atualização da penelope ainda não existe. Baixando arquivos necessários...'; tput sgr0
        wget github.com/JoaoPedro-Ribeiro/updatetzdata/raw/main/tzupdater.jar

        tput setaf 2; echo 'Mudandos os arquivos necessários de local...'; tput sgr0   
        mv tzupdater.jar /tmp

    fi

    tput setaf 2; echo 'Instalando atualizacao da Penelope...'; tput sgr0
    /opt/jre1.8.0_25/bin/java -jar /tmp/tzupdater.jar -f

    tput setaf 2; echo 'Reiniciando serviço da Penelope'; tput sgr0
    initctl stop adapter
    initctl start adapter

    tput setaf 2; echo 'Confira a versão atual para validar a atualização...'; tput sgr0
    /opt/jre1.8.0_25/bin/java -jar /tmp/tzupdater.jar -V

    VERIFICACAOPENELOPE=$(/opt/jre1.8.0_25/bin/java -jar /tmp/tzupdater.jar -V |grep JRE) #Coleta qual a versão atual do tzdata da penelope

    if [[ $VERIFICACAOPENELOPE =~ "tzdata2021" ]]; 
    then

        tput setaf 2; echo "Atualização da penelope realizada com sucesso!"; tput sgr0
    
    else

        tput setaf 1; echo "Atualização da penelope falhou!"; tput sgr0
    fi

fi