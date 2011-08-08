#
# Proyecto final del Curso C y Linux para Sistemas Empotrados
#
# @Author: Adrian Bonilla Bonilla
# @Author: David Astua Mora
# @Author: Luis Carlos Chacon Salas
#

FS=fs
CROSSC=crossc

KERNEL=kernel.tar.gz
LIGHTHTTP=lighthttp.tar.gz
BUSYBOX=busybox.tar.gz
IPTOOLS=iptools.tar.gz



all:	initfolders unpack createfs createscripts crosscompile install

#
# Creacion folders para gestion del proyecto
# fs = Estructura File System 
# crossc = Programas cross compilados 
#
initfolders: 
	@mkdir $(FS)
	@mkdir $(CROSSC)

#
# Descomprimimos los archivos necesarios para realizar el proyecto
# Aplicaciones:
#  lighthttp
#  kernel
#  iptools
#  busybox
unpack:
	@tar $(KERNEL)
	@tar $(BUSYBOX)
	@tar $(LIGHTHTTP)
	@tar $(IPTOOLS)

#
# Creacion de la jerarquia de folder del sistema operativo
#
createfs:
	@cd $(FS)
	@mkdir bin dev etc lib proc sbin tmp usr var
	@chmod 1777 tmp
	@mkdir usr/bin usr/lib usr/sbin
	@mkdir var/lib var/lock var/log var/run var/tmp
	@chmod 1777 var/tmp
	@cd /dev/
	@sudo mknod -m 600 mem c 1 1
	@sudo mknod -m 666 null c 1 3
	@sudo mknod -m 666 zero c 1 5
	@sudo mknod -m 644 random c 1 8
	@sudo mknod -m 600 tty0 c 4 0
	@sudo mknod -m 600 tty1 c 4 1
	@sudo mknod -m 600 ttyS0 c 4 64
	@sudo mknod -m 666 tty c 5 0
	@sudo mknod -m 600 console c 5 1

#
# Creacion de los scripts basicos de arranque del sistema
# Tomados del FS proveido por RidgeRun
#
createscripts:

#
# Se cross compilan las aplicaciones asignadas y el kernel
# 
#
crosscompile: kernel busybox lighthttp iptools

# 
# Se copian las aplicaciones cross compiladas dentro del filesystem
#
install:

