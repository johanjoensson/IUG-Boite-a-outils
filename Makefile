SRCDIR              = ..
MANYMOUSE_SRC       = ${SRCDIR}/ManyMouse
OBJDIR              = ./objs

OPT                 = 0
ifeq (${OPT},0)
  OPTFLAGS          = -g -O0
  OPTADAFLAGS       =
else
  OPTFLAGS          = -O3
  OPTADAFLAGS       = -gnatn -gnatp
endif

CC                  = gcc
CCFLAGS             = -c ${OPTFLAGS} -I.. -I../ManyMouse

GNAT_COMPILE        = gcc
GNAT_COMPILE_FLAGS  = -c ${OPTFLAGS} ${OPTADAFLAGS}

GNAT_MAKE           = gnatmake
GNAT_MAKE_FLAGS     = ${OPTFLAGS} ${OPTADAFLAGS}

LIBS                = -lSDL -lSDL_ttf -ldl

COBJS               :=  ${OBJDIR}/ada_sdl.o \
                        ${OBJDIR}/ada_Cmanymouse.o \
                        ${OBJDIR}/linux_evdev.o \
                        ${OBJDIR}/macosx_hidutilities.o \
                        ${OBJDIR}/macosx_hidmanager.o \
                        ${OBJDIR}/windows_wminput.o \
                        ${OBJDIR}/x11_xinput.o \
                        ${OBJDIR}/manymouse.o

ADASRC              :=  ada_sdl_init.adb \
                        ${SRCDIR}/ada_sdl_init.ads \
                        ${SRCDIR}/ada_manymouse.ads \
                        ${SRCDIR}/ada_sdl_entryproc.adb \
                        ${SRCDIR}/ada_sdl_event.ads \
                        ${SRCDIR}/ada_sdl_keyboard.ads \
                        ${SRCDIR}/ada_sdl_main.adb \
                        ${SRCDIR}/ada_sdl_main.ads \
                        ${SRCDIR}/ada_sdl_mouse.ads \
                        ${SRCDIR}/ada_sdl_video.ads \
                        ${SRCDIR}/gr_shapes.adb \
                        ${SRCDIR}/gr_shapes.ads \
                        ${SRCDIR}/example_package.adb \
                        ${SRCDIR}/example_package.ads \
						${SRCDIR}/aux_fct.adb \
						${SRCDIR}/aux_fct.ads \
						${SRCDIR}/drawline_pkg.adb \
						${SRCDIR}/drawline_pkg.ads \
						${SRCDIR}/event_handling.adb \
						${SRCDIR}/event_handling.ads \

ada_sdl_entryproc: ${COBJS} ${ADASRC}
	${GNAT_MAKE} ${GNAT_MAKE_FLAGS} ${SRCDIR}/ada_sdl_entryproc.adb -I${OBJDIR} -I. -largs ${COBJS} ${LIBS}

${OBJDIR}/ada_sdl.o: ${SRCDIR}/ada_sdl.h ${SRCDIR}/ada_sdl.c
	${CC} ${CCFLAGS} ${SRCDIR}/ada_sdl.c                      -o ${OBJDIR}/ada_sdl.o

${OBJDIR}/ada_Cmanymouse.o: ${SRCDIR}/ada_manymouse.c
	${CC} ${CCFLAGS} ${SRCDIR}/ada_manymouse.c                -o ${OBJDIR}/ada_Cmanymouse.o

${OBJDIR}/linux_evdev.o : ${MANYMOUSE_SRC}/linux_evdev.c
	${CC} ${CCFLAGS} ${MANYMOUSE_SRC}/linux_evdev.c           -o ${OBJDIR}/linux_evdev.o

${OBJDIR}/macosx_hidutilities.o : ${MANYMOUSE_SRC}/macosx_hidutilities.c
	${CC} ${CCFLAGS} ${MANYMOUSE_SRC}/macosx_hidutilities.c   -o ${OBJDIR}/macosx_hidutilities.o

${OBJDIR}/macosx_hidmanager.o : ${MANYMOUSE_SRC}/macosx_hidmanager.c
	${CC} ${CCFLAGS} ${MANYMOUSE_SRC}/macosx_hidmanager.c     -o ${OBJDIR}/macosx_hidmanager.o

${OBJDIR}/windows_wminput.o : ${MANYMOUSE_SRC}/windows_wminput.c
	${CC} ${CCFLAGS} ${MANYMOUSE_SRC}/windows_wminput.c       -o ${OBJDIR}/windows_wminput.o

${OBJDIR}/x11_xinput.o : ${MANYMOUSE_SRC}/x11_xinput.c
	${CC} ${CCFLAGS} ${MANYMOUSE_SRC}/x11_xinput.c            -o ${OBJDIR}/x11_xinput.o

${OBJDIR}/manymouse.o : ${MANYMOUSE_SRC}/manymouse.c
	${CC} ${CCFLAGS} ${MANYMOUSE_SRC}/manymouse.c             -o ${OBJDIR}/manymouse.o

clean:
	rm ${OBJDIR}/* ada_sdl_entryproc
