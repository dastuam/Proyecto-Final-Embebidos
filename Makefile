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

PATH:=/arm-2009q1/bin:$(PATH)
export PATH

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
	#@tar -C $(CROSSC) -xf $(KERNEL)
	#@tar -C $(CROSSC) -xf $(BUSYBOX)
	#@tar -C $(CROSSC) -xf $(LIGHTHTTP)
	@tar -C $(CROSSC) -xf $(IPTOOLS)

#
# Creacion de la jerarquia de folder del sistema operativo
#
createfs:
	@cd $(FS); mkdir bin dev etc lib proc sbin tmp usr var
	@cd $(FS); chmod 1777 tmp
	@cd $(FS); mkdir usr/bin usr/lib usr/sbin
	@cd $(FS); mkdir var/lib var/lock var/log var/run var/tmp
	@cd $(FS); chmod 1777 var/tmp
	@cd $(FS)/dev/; sudo mknod -m 600 mem c 1 1
	@cd $(FS)/dev/; sudo mknod -m 666 null c 1 3
	@cd $(FS)/dev/; sudo mknod -m 666 zero c 1 5
	@cd $(FS)/dev/; sudo mknod -m 644 random c 1 8
	@cd $(FS)/dev/; sudo mknod -m 600 tty0 c 4 0
	@cd $(FS)/dev/; sudo mknod -m 600 tty1 c 4 1
	@cd $(FS)/dev/; sudo mknod -m 600 ttyS0 c 4 64
	@cd $(FS)/dev/; sudo mknod -m 666 tty c 5 0
	@cd $(FS)/dev/; sudo mknod -m 600 console c 5 1

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

kernel:

busybox:

lighthttp:

iptools:
	@cd $(CROSSC)/iptools; ./configure --host=arm-none-linux-gnueabi; make

# 
# Se copian las aplicaciones cross compiladas dentro del filesystem
#
install:

clean:
	@rm -rf $(FS)
	@rm -rf $(CROSSC)

