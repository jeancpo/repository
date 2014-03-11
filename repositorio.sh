#!/bin/bash
################################################################################
#                     REPUBLICA BOLIVARIANA DE VENEZUELA
#		 
#				CORPIVENSA
# NOMBRE: REPOSITORIO-CANAIMA
# VERSIÓN: 1.0
# TIPO DE PROGRAMA: ACTUALIZAR REPOSITORIO CANAIMA
# FUNCIÓN: ESTABLECER UN ARCHIVO SOURCES.LIST PARA TODAS LAS CANAIMA
# MODIFICADO POR: JEAN C. PARRA
# EMAIL: jcparra@corpivensa.gob.ve
# FECHA DE LANZAMIENTO DE LA PRIMERA VERSIÓN (1.0): 06/11/2013
#
##############################################################################

#constanstes
servidor=ftp.br.debian.org
seguridad=security.debian.org
#backports=backports.debian.org
debian=debian
parametros_deb="main contrib non-free"

#funciones
existe_archivo () {
if [ ! -d "$1" ]; then
  # no existe
        case "$2" in
                source*) touch "/etc/apt/sources.list";;
                aptconf) cat /dev/null > /etc/apt/apt.conf;;
        esac
fi
}

identicficacion(){
codename=$(lsb_release -sc)
}

#generar url
genera_url (){
#sistema base
url_deb="deb http://${servidor}/${debian} ${codename} ${parametros_deb}"
#seguridad
url_seg="deb http://${seguridad}/ ${codename}/updates ${parametros_deb}"
#backports
#url_back="deb http://${backports}/debian-backports ${codename}-backports ${parametros_deb}"

}

#ESPERA A QUE SE PULSE UNA TECLA
pulsar_una_tecla ()
{
echo
read TECLA
echo
if [ "$1" = echo "Pulsa una tecla para salir..." ]
then
	exit 1
fi
}

#comprobar root
comprobar_root ()
{
ROOT=`whoami`
if [ "$ROOT" != "root" ]
then
	echo "                                            "
	echo "ERROR: Necesitas permisos de root para poder"
	echo "       ejecutar este script                 "
	echo "                                            "
	pulsar_una_tecla cecho "Pulsa una tecla para salir..." 
fi
}

# Actualiza el sistema y remueve paquetes no necesarios
update() {
    echo "\n********** ACTUALIZANDO EL SISTEMA **********\n"
    echo "1. ACTUALIZANDO LA LISTA DE PAQUETES...\n"
    sudo apt-get update 1> /dev/null 
    echo "2. ACTUALIZANDO...\n"
    sudo apt-get upgrade
    echo "\n3. CHECANDO DEPENDENCIAS INCUMPLIDAS...\n"
    sudo apt-get check  1> /dev/null 
    echo "4. CORRIGIENDO DEPENDENCIAS INCUMPLIDAS...\n"
    sudo apt-get install -fy 1> /dev/null 
    echo "********** ELIMINADO PAQUETES BASURA **********\n"
    echo "5. DESINSTALANDO PAQUETES EN DESUSO...\n"
    sudo apt-get autoremove
    echo "\n6. BORRANDO ARCHIVOS DESCARGADOS...\n"
    sudo apt-get autoclean 1> /dev/null 
    echo "7. BORRANDO ARCHIVOS ANTIGUOS DESCARGADOS...\n"
    sudo apt-get clean 1> /dev/null 
}

## Inicio Programa ##
comprobar_root
identicficacion

### Verificación del /etc/apt/source.list en sistema
if existe_archivo /etc/apt/sources.list source ; then
	
	existe_archivo /etc/apt/apt.conf aptconf

	#respaldo y limpieza de source.list
	cp /etc/apt/sources.list /etc/apt/sources.list.old
	cat /dev/null > /etc/apt/sources.list

	##generar
	genera_url
	echo "#        		Repositorios                        ">> /etc/apt/sources.list
	echo "###########      REPOSITORIO DEBIAN      #############">> /etc/apt/sources.list
	echo $url_deb >> /etc/apt/sources.list
	echo "########### REPOSITORIO SEGURIDAD DEBIAN #############">> /etc/apt/sources.list
	echo $url_seg >> /etc/apt/sources.list

	echo "Sources.list Generado-->"
	cat /etc/apt/sources.list
	update
	echo "########### ^^ LISTO ^^ #############"

fi

#fin
exit 0
