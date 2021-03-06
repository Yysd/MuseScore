#=============================================================================
#  Mscore
#  Linux Music Score Editor
#  $Id:$
#
#  Copyright (C) 2002-2012 by Werner Schweer and others
#
#  This program is free software; you can redistribute it and/or modify
#  it under the terms of the GNU General Public License version 2.
#
#  This program is distributed in the hope that it will be useful,
#  but WITHOUT ANY WARRANTY; without even the implied warranty of
#  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#  GNU General Public License for more details.
#
#  You should have received a copy of the GNU General Public License
#  along with this program; if not, write to the Free Software
#  Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.
#=============================================================================

REVISION  = `cat mscore/revision.h`
CPUS      = `grep -c processor /proc/cpuinfo`
# Avoid build errors when processor=0 (as in m68k)
ifeq ($(CPUS), 0)
  CPUS=1
endif

PREFIX    = "/usr/local"
VERSION   = "2.1b-${REVISION}"
#VERSION = 2.1.0

#
# change path to include your Qt5 installation
#
BINPATH      = ${PATH}

release:
	if test ! -d build.release; then mkdir build.release; fi; \
      cd build.release;                          \
      export PATH=${BINPATH};                    \
      cmake -DCMAKE_BUILD_TYPE=RELEASE	       \
  	  -DCMAKE_INSTALL_PREFIX="${PREFIX}" ..;   \
      make lrelease;                             \
      make manpages;                             \
      make -j ${CPUS};                           \


debug:
	if test ! -d build.debug; then mkdir build.debug; fi; \
      cd build.debug;                                       \
      export PATH=${BINPATH};                               \
      cmake -DCMAKE_BUILD_TYPE=DEBUG	                  \
  	  -DCMAKE_INSTALL_PREFIX="${PREFIX}" ..;              \
      make lrelease;                                        \
      make manpages;                                        \
      make -j ${CPUS};                                      \


#
#  win32
#     cross compile windows package
#     NOTE: there are some hardcoded path in CMake - files
#           will probably only work on my setup (ws)
#
win32:
	if test ! -d win32build;                         \
         then                                          \
            mkdir win32build;                          \
      	if test ! -d win32install;                 \
               then                                    \
                  mkdir win32install;                  \
            fi;                                        \
            cd win32build;                             \
            cmake -DCMAKE_TOOLCHAIN_FILE=../build/mingw32.cmake -DCMAKE_INSTALL_PREFIX=../win32install -DCMAKE_BUILD_TYPE=DEBUG  ..; \
            make lrelease;                             \
            make -j ${CPUS};                           \
            make install;                              \
            make package;                              \
         else                                          \
            echo "build directory win32build does alread exist, please remove first"; \
         fi

#
# clean out of source build
#

clean:
	-rm -rf build.debug build.release
	-rm -rf win32build win32install

revision:
	@git rev-parse --short HEAD > mscore/revision.h

version:
	@echo ${VERSION}

install: release
	cd build.release \
	&& make install/strip \
	&& update-mime-database "${PREFIX}/share/mime" \
	&& gtk-update-icon-cache -f -t "${PREFIX}/share/icons/hicolor"

installdebug: debug
	cd build.debug \
	&& make install \
	&& update-mime-database "${PREFIX}/share/mime" \
	&& gtk-update-icon-cache -f -t "${PREFIX}/share/icons/hicolor"

uninstall:
	cd build.release \
	&& xargs rm < install_manifest.txt \
	&& update-mime-database "${PREFIX}/share/mime" \
	&& gtk-update-icon-cache -f -t "${PREFIX}/share/icons/hicolor"

uninstalldebug:
	cd build.debug \
	&& xargs rm < install_manifest.txt \
	&& update-mime-database "${PREFIX}/share/mime" \
	&& gtk-update-icon-cache -f -t "${PREFIX}/share/icons/hicolor"

#
#  linux
#     linux binary package build
#
unix:
	if test ! -d linux;                          \
         then                                      \
            mkdir linux;                           \
            cd linux; \
            cmake -DCMAKE_BUILD_TYPE=RELEASE  ../mscore; \
            make -j${CPUS} -f Makefile;            \
            make package;                          \
         else                                      \
            echo "build directory linux does alread exist, please remove first";  \
         fi

doxy:
	doxygen build.debug/Doxyfile
doxylib:
	doxygen build.debug/Doxyfile-LibMscore


