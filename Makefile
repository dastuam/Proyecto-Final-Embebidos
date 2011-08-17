#
# Proyecto final del Curso C y Linux para Sistemas Empotrados
#
# @Author: Adrian Bonilla Bonilla
# @Author: David Astua Mora
# @Author: Luis Carlos Chacon Salas
#

FS=fs
CROSSC=crosscompile

KERNEL=linux-2.6.29.tar.gz
KERNEL_FOLDER=kernel
LIGHTHTTP_URL=http://download.lighttpd.net/lighttpd/releases-1.4.x/lighttpd-1.4.28.tar.gz
LIGHTHTTP_NAME=lighttpd-1.4.28.tar.gz
BUSYBOX_URL=http://www.busybox.net/downloads/busybox-1.18.5.tar.bz2
BUSYBOX_NAME=busybox-1.18.5.tar.bz2
IPTOOLS=iptools.tar.gz
LIB_PATH=/opt/arm-2009q1/arm-none-linux-gnueabi/libc/lib/
DOWNLOAD=TRUE

PATH:=/arm-2009q1/bin:$(PATH)
export PATH

all:	initfolders unpack createfs createscripts crosscompile install-kernel

#
# Descomprimimos los archivos necesarios para realizar el proyecto
# Aplicaciones:
#  lighthttp
#  kernel
#  iptools
#  busybox
unpack:
ifeq ($(DOWNLOAD), TRUE)
	@echo "Downloading and unpacking software"
	@tar -C $(CROSSC) -xf $(KERNEL)
	@wget $(BUSYBOX_URL)
	@tar -C $(CROSSC) -xjf $(BUSYBOX_NAME)
	@wget $(LIGHTHTTP_URL) 
	@tar -C $(CROSSC) -xf $(LIGHTHTTP_NAME)
	@tar -C $(CROSSC) -xf $(IPTOOLS)
else
	@echo "Unpacking software"
	@tar -C $(CROSSC) -xf $(KERNEL)
	@tar -C $(CROSSC) -xf $(BUSYBOX_NAME)
	@tar -C $(CROSSC) -xf $(LIGHTHTTP_NAME)
	@tar -C $(CROSSC) -xf $(IPTOOLS)
endif
	@echo "Finish Unpack"

#
# Creacion de la jerarquia de folder del sistema operativo
#
createfs:
	@echo "Creating Filesystem"
	@cd $(FS); mkdir bin dev etc lib proc sbin tmp usr var sys
	@cd $(FS); chmod 1777 tmp; mkdir srv; echo "Hello" srv/index.html
	@cd $(FS); mkdir usr/bin usr/lib usr/sbin
	@cd $(FS); mkdir var/lib var/lock var/log var/run var/tmp
	@cd $(FS); chmod 1777 var/tmp
	@cd $(FS); mkdir -p usr/local/lib
	@echo "Getting libraries from toolchain"
	@cd $(FS); cp -r $(LIB_PATH)/* lib/
	@echo "Creating device nodes"
	@cd $(FS)/dev/; sudo mknod -m 600 mem c 1 1
	@cd $(FS)/dev/; sudo mknod -m 666 null c 1 3
	@cd $(FS)/dev/; sudo mknod -m 666 zero c 1 5
	@cd $(FS)/dev/; sudo mknod -m 644 random c 1 8
	@cd $(FS)/dev/; sudo mknod -m 600 tty0 c 4 0
	@cd $(FS)/dev/; sudo mknod -m 600 tty1 c 4 1
	@cd $(FS)/dev/; sudo mknod -m 600 ttyS0 c 4 64
	@cd $(FS)/dev/; sudo mknod -m 666 tty c 5 0
	@cd $(FS)/dev/; sudo mknod -m 600 console c 5 1
	@echo "Finish Filesystem Creation"

#
# Creacion de los scripts basicos de arranque del sistema
# Tomados del FS proveido por RidgeRun
#
createscripts:
	@cp -r etc/* fs/etc/

kernel:
	@echo "Patching and building kernel"
	@if test -d $(CROSSC)/$(subst .tar.gz,,$(KERNEL))/patches.orig; then \
		rm -rf $(CROSSC)/$(subst .tar.gz,,$(KERNEL))/patches; \
		mv $(CROSSC)/$(subst .tar.gz,,$(KERNEL))/patches.orig \
			$(CROSSC)/$(subst .tar.gz,,$(KERNEL))/patches; \
	fi
	@cd $(CROSSC)/$(subst .tar.gz,,$(KERNEL))/patches; quilt import ../../makefile_arm.patch
	@cd $(CROSSC)/$(subst .tar.gz,,$(KERNEL))/patches/; \
		quilt pop -a -f; sed -i 's/rr-sdk-integration.patch//g' series; quilt push -a
	@cd $(CROSSC)/$(subst .tar.gz,,$(KERNEL))/; \
		make -j4 ARCH=arm; \
		make uImage
	@echo "Finish Kernel build"

install-kernel:
	@if ! test -d $(KERNEL_FOLDER); then \
		mkdir $(KERNEL_FOLDER); \
	fi
	@cp $(CROSSC)/$(subst .tar.gz,,$(KERNEL))/arch/arm/boot/uImage $(KERNEL_FOLDER)/ 

busybox:
	@echo "Building BusyBox"
	@cd $(CROSSC)/$(subst .tar.bz2,,$(BUSYBOX_NAME)); \
		make defconfig; \
		make TARGET_ARCH=arm CROSS_COMPILE=arm-none-linux-gnueabi-; \
		make install TARGET_ARC=arm CROSS_COMPILE=arm-none-linux-gnueabi- CONFIG_PREFIX=installdir; \
		cp -r installdir/* ../../fs/
	@echo "Finish building BusyBox"
 		
lighthttp:
	@echo "Building Lighthttp"
	@if test ! -d $(CROSSC)/$(subst .tar.gz,,$(LIGHTHTTP_NAME))/installdir; then \
		mkdir $(CROSSC)/$(subst .tar.gz,,$(LIGHTHTTP_NAME))/installdir; \
	fi
	@cd $(CROSSC)/$(subst .tar.gz,,$(LIGHTHTTP_NAME)); \
		./configure --host=arm-none-linux-gnueabi --without-pcre --without-zlib --without-bzip2; \
		make; \
		make install DESTDIR=`pwd`/installdir; \
		cp -r installdir/usr/local/sbin/* ../../fs/usr/sbin/; \
		cp -r installdir/usr/local/lib/* ../../fs/usr/local/lib/
	@echo "Finish building Lighthttp"

iptools:
	@echo "Building IPtools"
	@if test ! -d $(CROSSC)/iptools/installdir; then \
		mkdir $(CROSSC)/iptools/installdir; \
	fi
	@cd $(CROSSC)/iptools; ./configure --host=arm-none-linux-gnueabi; \
		make; make install DESTDIR=`pwd`/installdir; \
		cp -r installdir/usr/local/bin/* ../../fs/usr/bin
	@echo "Finish building IPtools"

.PHONY:
#
# Se cross compilan las aplicaciones asignadas y el kernel
# 
#
crosscompile: kernel busybox lighthttp iptools

#
# Remove all the directories and files created by
# the makefile
#
clean-all: clean clean-download clean-done
	

#
# Remove temporal source folder and filesystem
#
clean:
	@rm -rf $(FS)
	@rm -rf $(CROSSC)
#
# Remove downloaded software
#
clean-download:
	@rm -rf $(LIGHTHTTP_NAME) 
	@rm -rf $(BUSYBOX_NAME)

#
# Remove the FS and the kernel
#
clean-done:
	@rm -rf $(FS)
	@rm -rf $(KERNEL_FOLDER)

#
# Creacion folders para gestion del proyecto
# fs = Estructura File System 
# crossc = Programas cross compilados 
#
initfolders: 
	@echo "Creating base folders 'fs' and 'crosscompile'"
	@mkdir $(FS)
	@mkdir $(CROSSC)
	@echo "Finished creating base folders 'fs' and 'crosscompile'"
