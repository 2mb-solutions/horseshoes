# makefile for mine racer and 2MB projects.
# adapted from the aspen mud makefile.
#compiler and project specific variables
OUTPUT=horseshoes

#compiler flags:
#enable if you want to profile.
PROF =
LINCXXFLAGS	= -g -std=c++11 -O2 -march=native -Wall -pedantic -Wextra -Wno-unused-variable \
 -Wno-unused-parameter -I/usr/include/speech-dispatcher -I/usr/include -Igame-kit/allegro_stuff \
 -Igame-kit/screen-reader -Igame-kit
MACCXXFLAGS       = -g -std=c++11 -O2 -march=native -Wall -pedantic -Wextra \
 -Wno-unused-variable -Wno-unused-parameter -I/usr/include -Igame-kit/allegro_stuff \
 -Igame-kit/screen-reader -Igame-kit -Igame-kit/allegro_stuff/include-mac \
 -framework ApplicationServices -framework OpenGL -framework OpenAL -framework AppKit \
 -framework CoreFoundation -framework AudioToolbox -framework IOKit
WINCXXFLAGS=/nologo /EHsc /MT /Igame-kit/allegro_stuff /Igame-kit/screen-reader \
 /Igame-kit/allegro_stuff/include-win /Igame-kit

#required libraries
LINLDFLAGS	= -lallegro_audio -lallegro_acodec -lallegro -lallegro_font -lspeechd
MACLDFLAGS      = -L/usr/local/lib -lallegro_main -lallegro_audio -lallegro_acodec \
 -lallegro -lallegro_font -framework ApplicationServices -framework OpenGL \
 -framework OpenAL -framework AppKit -framework CoreFoundation -framework AudioToolbox -framework IOKit
WINLDFLAGS=/nologo /subsystem:windows,5.01 /libpath:game-kit/allegro_stuff/win-lib32 \
 /libpath:game-kit/screen-reader dolapi.lib saapi32.lib nvdaControllerClient32.lib allegro_acodec.lib  allegro_audio.lib allegro.lib allegro_font.lib \
 FLAC.lib opengl32.lib ogg.lib vorbis.lib vorbisfile.lib dumb.lib freetype.lib winmm.lib psapi.lib gdi32.lib opus.lib opusfile.lib

# directory with windows dlls to copy
WINDLLDIR=game-kit/{allegro_stuff,screen-reader}/win-distrib32/*
#formatting specific flags
FORMATTER = astyle
FORMAT_FLAGS = --style=gnu -Q

# programs that shouldn't change between windows and other oses
RM = rm -f
ECHO = echo

	#source files to compile:
# game-kit files, only update if game-kit has been updated.
GK_S_FILES= game-kit/allegro_stuff/sound.cpp game-kit/allegro_stuff/keyboard.cpp \
 game-kit/screen-reader/screen_reader.cpp game-kit/allegro_stuff/dynamic_menu.cpp \
 game-kit/menu_helper.cpp game-kit/misc.cpp game-kit/soundplayer.cpp \
 game-kit/allegro_stuff/sound_pool_item.cpp game-kit/allegro_stuff/sound_pool.cpp
# regular source files, specific to the game.
S_FILES = play.cpp game.cpp

# does this program have a demo?
#HASDEMO = true
# or if not
HASDEMO =

ifeq ($(HASDEMO),true)
# files that depend on demo.h
# these files should be updated per project
DEMO_H_FILES = play.cpp

# demo and full program defines in demo.h
DEMODEFINE = \#define DEMO true
FULLDEFINE = \#define DEMO false
endif

# resources, items that should be copied into the package. (no spaces for now)
RESOURCES =sounds

###
###YOU SHOULD NOT MODIFY ANYTHING PAST THIS POINT.
###IF YOU HAVE CHANGES, MAKE THEM ABOVE TO THE FLAGS.
###

# demo variable
export DEMO ?=

# os variables for os specific compilation and packaging.
ifeq ($(OS),Windows_NT)
CXX := $(or $(strip $(CXX)),cl)
CXXFLAGS := $(WINCXXFLAGS) $(CXXFLAGS)
LDFLAGS := $(WINLDFLAGS) $(LDFLAGS)
OUTPUT := $(OUTPUT).exe
#program defines
MAKE := $(or $(strip $(MAKE)),mingw32-make -s)
LINK = link
OSVAR = win32
else
UNAME_S := $(shell uname -s)
ifeq ($(UNAME_S),Linux)
CXX := $(or $(strip $(CXX)),g++)
CXXFLAGS := $(LINCXXFLAGS) $(CXXFLAGS)
LDFLAGS := $(LINLDFLAGS) $(LDFLAGS)

#program defines
MAKE := $(or $(strip $(MAKE)),make -s)
OSVAR = linux
else #macOS
CXX := $(or $(strip $(CXX)),g++)
CXXFLAGS := $(MACCXXFLAGS) $(CXXFLAGS)
LDFLAGS := $(MACLDFLAGS) $(LDFLAGS)

#program defines
MAKE := $(or $(strip $(MAKE)),make -s)
OSVAR = mac
endif
endif

ifneq ($(OSVAR),win32)

O_FILES += $(patsubst %.cpp,%.o, $(filter %.cpp, $(S_FILES)))
O_FILES += $(patsubst %.cpp,%.o, $(filter %.cpp, $(GK_S_FILES)))
else
O_FILES += $(patsubst %.cpp,%.obj, $(filter %.cpp, $(S_FILES)))
O_FILES += $(patsubst %.cpp,%.obj, $(filter %.cpp, $(GK_S_FILES)))
endif

all: $(OUTPUT)

$(OUTPUT): $(O_FILES)
	@$(RM) $(OUTPUT)
	@$(ECHO) "Linking."
ifneq ($(OSVAR),win32)
	@$(CXX) $(CXXFLAGS) -o $(OUTPUT) $(O_FILES) $(LDFLAGS)
else
	@$(LINK) $(O_FILES) $(LDFLAGS) /out:$(OUTPUT)
endif

ifneq ($(OSVAR),win32)
%.o: %.cpp
else
%.obj: %.cpp
endif
	@$(ECHO) "Compiling $<."
ifneq ($(OSVAR),win32)
	@$(CXX) $(PROF) -c $(CXXFLAGS) -o $(patsubst %.cpp,%.o, $<) $<
else
	@$(CXX) /c $(CXXFLAGS) /Fo$(subst .cpp,.obj,$<) $<
endif

ifeq ($(HASDEMO),true)
ifneq ($(OSVAR),win32)
$(patsubst %.cpp,%.o,$(DEMO_H_FILES)): demo.h
else
$(patsubst %.cpp,%.obj,$(DEMO_H_FILES)): demo.h
endif

demo.h:
	@if [ ! -f demo.h ];then $(ECHO) "Demo.h does not exist, setting to default full program contents."; $(ECHO) "$(FULLDEFINE)" > demo.h;fi
endif

fullclean: clean packageclean

packageclean:
	@$(ECHO) "Cleaning up packages."
	@$(RM) -r packages

clean:
	@$(ECHO) "Cleaning objects and other binary files"
	@$(RM) $(O_FILES)
	@$(RM) $(OUTPUT)

format:
ifneq ($(OSVAR),win32)
	@$(ECHO) "Formatting"
	@$(FORMATTER) $(FORMAT_FLAGS) $(S_FILES)
	@find . -name "*.orig" -exec $(RM) -f {} \;
	@$(ECHO) "Done."
else
	@$(ECHO) "Formatting isn't implemented on windows yet"
endif

ifeq ($(HASDEMO),true)
demo:
	@$(ECHO) "Building demo program."
	@demofile="$$(cat demo.h)";if [ "$${demofile}" != "$(DEMODEFINE)" ];then $(ECHO) "$(DEMODEFINE)" > demo.h;fi
	@$(MAKE)

full:
	@$(ECHO) "Building full program"
	@demofile="$$(cat demo.h)";if [ "$${demofile}" != "$(FULLDEFINE)" ];then $(ECHO) "$(FULLDEFINE)" > demo.h;fi
	@$(MAKE)
endif

ifeq ($(HASDEMO),true)
package: package_demo package_full
package_demo: DEMO = -demo
package_demo: demo
	@$(MAKE) do_package
package_full: full
	@$(MAKE) do_package
else
package: package_full
package_full:
	@$(MAKE) do_package
endif

do_package:
	@$(ECHO) "Building release package"
ifneq ($(OSVAR),mac)
	@if [ -d distrib ]; then \
	$(RM) -r distrib;\
	fi
	@mkdir distrib
	@for x in "$(RESOURCES)";do \
	cp -R $$x distrib;\
done
ifeq ($(OSVAR),linux)
	@mkdir distrib/lib
	@libPath=/usr/lib;\
	allegroVersion="$$(ls -1 $${libPath}/liballegro.so.*.*.* | head -n 1)";\
	allegroVersion="$${allegroVersion#*.so.}";\
	opusVersion="$$(ls -1 $${libPath}/libopus.so.*.*.* | head -n 1)";\
	opusVersion="$${opusVersion#*.so.}";\
	opusfileVersion="$$(ls -1 $${libPath}/libopusfile.so.*.*.* | head -n 1)";\
	opusfileVersion="$${opusfileVersion#*.so.}";\
	speechdVersion="$$(ls -1 $${libPath}/libspeechd.so.*.*.* | head -n 1)";\
	speechdVersion="$${speechdVersion#*.so.}";\
	vorbisVersion="$$(ls -1 $${libPath}/libvorbis.so.*.*.* | head -n 1)";\
	vorbisVersion="$${vorbisVersion#*.so.}";\
	vorbisfileVersion="$$(ls -1 $${libPath}/libvorbisfile.so.*.*.* | head -n 1)";\
	vorbisfileVersion="$${vorbisfileVersion#*.so.}";\
	oggVersion="$$(ls -1 $${libPath}/libogg.so.*.*.* | head -n 1)";\
	oggVersion="$${oggVersion#*.so.}";\
	soFiles=(\
	"liballegro.so.$${allegroVersion}" \
	"liballegro_audio.so.$${allegroVersion}" \
	"liballegro_acodec.so.$${allegroVersion}" \
	"liballegro_font.so.$${allegroVersion}" \
	"libopus.so.$${opusVersion}" \
	"libopusfile.so.$${opusfileVersion}" \
	"libspeechd.so.$${speechdVersion}" \
	"libvorbis.so.$${vorbisVersion}" \
	"libvorbisfile.so.$${vorbisfileVersion}" \
	"libogg.so.$${oggVersion}"\
	);\
	for i in $${soFiles[@]} ; do \
	if [[ "$$i" =~ liballegro* ]]; then \
	cp "$${libPath}/$${i}" "distrib/lib/$${i%.*}";\
	else \
	cp "$${libPath}/$${i}" "distrib/lib/$${i%.*.*}";\
	fi;\
	done
	@export LD_RUN_PATH="\$$ORIGIN/lib/";\
	$(MAKE);\
	unset LD_RUN_PATH
else
	@for x in $$(ls -1 $(WINDLLDIR));do \
	cp $$x distrib;\
done
	@$(MAKE)
endif
	@cp $(OUTPUT) distrib
	@if [ ! -d packages ];then mkdir packages;fi
ifneq ($(OSVAR),win32)
	@if [ -d packages/$(subst .exe,,$(OUTPUT))-$(OSVAR)-$$(uname -m |tr '_' '-')$(DEMO) ];then $(RM) -r packages/$(subst .exe,,$(OUTPUT))-$(OSVAR)-$$(uname -m |tr '_' '-')$(DEMO);fi
	@mv distrib packages/$(subst .exe,,$(OUTPUT))-$(OSVAR)-$$(uname -m |tr '_' '-')$(DEMO)
	@$(RM) packages/$(subst .exe,,$(OUTPUT))-$(OSVAR)-$$(uname -m |tr '_' '-')$(DEMO).tar.xz
	@cd packages;\
	tar -cJRf $(subst .exe,,$(OUTPUT))-$(OSVAR)-$$(uname -m |tr '_' '-')$(DEMO).tar.xz $(subst .exe,,$(OUTPUT))-$(OSVAR)-$$(uname -m |tr '_' '-')$(DEMO)
	@$(RM) -r packages/$(subst .exe,,$(OUTPUT))-$(OSVAR)-$$(uname -m |tr '_' '-')$(DEMO)
else
	@if [ -d packages/$(subst .exe,,$(OUTPUT))-$(OSVAR)$(DEMO) ];then $(RM) -r packages/$(subst .exe,,$(OUTPUT))-$(OSVAR)$(DEMO);fi
	@mv distrib packages/$(subst .exe,,$(OUTPUT))-$(OSVAR)$(DEMO)
	@$(RM) packages/$(subst .exe,,$(OUTPUT))-$(OSVAR)$(DEMO).zip
	@cd packages;\
	7z a -r $(subst .exe,,$(OUTPUT))-$(OSVAR)$(DEMO).zip $(subst .exe,,$(OUTPUT))-$(OSVAR)$(DEMO)
	@$(RM) -r packages/$(subst .exe,,$(OUTPUT))-$(OSVAR)$(DEMO)
endif
else
	@if [ -d "$(OUTPUT)$(DEMO).app" ];then $(RM) -r $(OUTPUT)$(DEMO).app;fi
	@mkdir $(OUTPUT)$(DEMO).app
	@mkdir -p $(OUTPUT)$(DEMO).app/Contents/MacOS
	@cp Info.plist $(OUTPUT)$(DEMO).app/Contents
	@cp $(OUTPUT)_launcher $(OUTPUT)$(DEMO).app/Contents/MacOS
	@mkdir $(OUTPUT)$(DEMO).app/Contents/Resources
	@for x in "$(RESOURCES)";do \
	cp -R $$x $(OUTPUT)$(DEMO).app/Contents/Resources;\
	done
	@$(MAKE)
	@cp $(OUTPUT) $(OUTPUT)$(DEMO).app/Contents/MacOS
	@$(MAKE) fix_names
	@if [ ! -d packages ];then mkdir packages;fi
	@if [ -f "packages/$(OUTPUT)-$(OSVAR)-x86-64$(DEMO).zip" ];then $(RM) "packages/$(OUTPUT)-$(OSVAR)-x86-64$(DEMO).zip";fi
	zip -r "packages/$(OUTPUT)-$(OSVAR)-x86-64$(DEMO).zip" "$(OUTPUT)$(DEMO).app"
endif
	@$(ECHO) "Find the built archive under the packages directory."

fix_names:
	@mkdir $(OUTPUT)$(DEMO).app/Contents/MacOS/lib;\
	@macpack $(OUTPUT)$(DEMO).app/Contents/MacOS/$(OUTPUT) -d lib
