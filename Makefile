# makefile for mine racer and 2MB projects.
# adapted from the aspen mud makefile.
#compiler and project specific variables
OUTPUT=horseshoes

#compiler flags:
#enable if you want to profile.
PROF =
LINCFLAGS	= -g -std=c++11 -O2 -march=native -Wall -pedantic -Wextra -Wno-unused-variable -Wno-unused-parameter -I/usr/include/speech-dispatcher -I/usr/include -Igame-kit/allegro_stuff -Igame-kit/screen-reader -Igame-kit
MACCFLAGS       = -g -std=c++11 -O2 -march=native -Wall -pedantic -Wextra -Wno-unused-variable -Wno-unused-parameter -I/usr/include/speech-dispatcher -I/usr/include -Igame-kit/allegro_stuff -Igame-kit/screen-reader -Igame-kit
WINCFLAGS=/nologo /EHsc /MT /Igame-kit/allegro_stuff /Igame-kit/screen-reader /Igame-kit/allegro_stuff/include-win /Igame-kit

#required libraries
LINLDFLAGS	= -lallegro_audio -lallegro_acodec -lallegro -lallegro_font -lspeechd
MACLDFLAGS      = -lallegro_audio -lallegro_acodec -lallegro -lallegro_font -lspeechd
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
GK_S_FILES= game-kit/allegro_stuff/sound.cpp game-kit/allegro_stuff/keyboard.cpp game-kit/screen-reader/screen_reader.cpp \
game-kit/allegro_stuff/dynamic_menu.cpp game-kit/menu_helper.cpp game-kit/misc.cpp game-kit/soundplayer.cpp game-kit/allegro_stuff/sound_pool_item.cpp \
game-kit/allegro_stuff/sound_pool.cpp
# regular source files, specific to the game.
S_FILES=  play.cpp game.cpp

# does this program have a demo?
#HASDEMO=true
# or if not
HASDEMO=

ifeq ($(HASDEMO),true)
# files that depend on demo.h
# these files should be updated per project
DEMO_H_FILES= play.cpp

# demo and full program defines in demo.h
DEMODEFINE=\#define DEMO true
FULLDEFINE=\#define DEMO false
endif

# resources, items that should be copied into the package. (no spaces for now)
RESOURCES=sounds

###
###YOU SHOULD NOT MODIFY ANYTHING PAST THIS POINT.
###IF YOU HAVE CHANGES, MAKE THEM ABOVE TO THE FLAGS.
###

# os variables for os specific compilation and packaging.
ifeq ($(OS),Windows_NT)
CXX=cl
CFLAGS = $(WINCFLAGS)
LDFLAGS=$(WINLDFLAGS)
OUTPUT:=$(OUTPUT).exe
#program defines
MAKE=mingw32-make -s
LINK=link
OSVAR=win32
else
UNAME_S := $(shell uname -s)
ifeq ($(UNAME_S),Linux)
CXX=g++
CFLAGS=$(LINCFLAGS)
LDFLAGS=$(LINLDFLAGS)

#program defines
MAKE=make -s
OSVAR=linux
else #macOS
CXX=g++
CFLAGS=$(MACCFLAGS)
LDFLAGS=$(MACLDFLAGS)

#program defines
MAKE=make -s
OSVAR=mac
endif
endif

ifneq ($(OSVAR),win32)
O_FILES += $(patsubst %.cpp,%.o, $(filter %.cpp, $(S_FILES)))
O_FILES += $(patsubst %.cpp,%.o, $(filter %.cpp, $(GK_S_FILES)))
else
O_FILES += $(patsubst %.cpp,%.obj, $(filter %.cpp, $(S_FILES)))
O_FILES += $(patsubst %.cpp,%.obj, $(filter %.cpp, $(GK_S_FILES)))
endif

all: $(O_FILES)
	@$(RM) $(OUTPUT)
	@$(ECHO) Linking.
ifneq ($(OSVAR),win32)
	@$(CXX) $(CFLAGS) -o $(OUTPUT) $(O_FILES) $(LDFLAGS)
else
	@$(LINK) $(O_FILES) $(LDFLAGS) /out:$(OUTPUT)
endif

ifneq ($(OSVAR),win32)
%.o: %.cpp
else
%.obj: %.cpp
endif
	@$(ECHO) Compiling $<.
ifneq ($(OSVAR),win32)
	@$(CXX) $(PROF) -c $(CFLAGS) -o $(patsubst %.cpp,%.o, $<) $<
else
	@$(CXX) /c $(CFLAGS) /Fo$(subst .cpp,.obj,$<) $<
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

clean:
	@$(ECHO) Cleaning objects and other binary files
	@$(RM) $(O_FILES)
	@$(RM) $(OUTPUT)

format:
ifneq ($(OSVAR),win32)
	@$(ECHO) Formatting
	@$(FORMATTER) $(FORMAT_FLAGS) $(S_FILES)
	@find . -name "*.orig" -exec rm -rf {} \;
	@$(ECHO) Done.
else
	@$(ECHO) Formatting isn't implemented on windows yet
endif

ifeq ($(HASDEMO),true)
demo:
	@$(ECHO) Building demo program.
	@demofile="$$(cat demo.h)";if [ "$${demofile}" != "$(DEMODEFINE)" ];then $(ECHO) "$(DEMODEFINE)" > demo.h;fi
	@$(MAKE)

full:
	@$(ECHO) Building full program
	@demofile="$$(cat demo.h)";if [ "$${demofile}" != "$(FULLDEFINE)" ];then $(ECHO) "$(FULLDEFINE)" > demo.h;fi
	@$(MAKE)
endif

ifeq ($(HASDEMO),true)
package: package_demo package_full
else
package:
	@$(ECHO) Building release package
	@if [ -d distrib ]; then \
	rm -rf distrib;\
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
	@if [ -d packages/$(subst .exe,,$(OUTPUT))-$(OSVAR)-$$(uname -m |tr '_' '-') ];then rm -rf packages/$(subst .exe,,$(OUTPUT))-$(OSVAR)-$$(uname -m |tr '_' '-');fi
	@mv distrib packages/$(subst .exe,,$(OUTPUT))-$(OSVAR)-$$(uname -m |tr '_' '-')
	@$(RM) packages/$(subst .exe,,$(OUTPUT))-$(OSVAR)-$$(uname -m |tr '_' '-').tar.xz
	@cd packages;\
	tar -cJRf $(subst .exe,,$(OUTPUT))-$(OSVAR)-$$(uname -m |tr '_' '-').tar.xz $(subst .exe,,$(OUTPUT))-$(OSVAR)-$$(uname -m |tr '_' '-')
	@rm -rf packages/$(subst .exe,,$(OUTPUT))-$(OSVAR)-$$(uname -m |tr '_' '-')
else
	@if [ -d packages/$(subst .exe,,$(OUTPUT))-$(OSVAR) ];then $(RM) -r packages/$(subst .exe,,$(OUTPUT))-$(OSVAR);fi
	@mv distrib packages/$(subst .exe,,$(OUTPUT))-$(OSVAR)
	@$(RM) packages/$(subst .exe,,$(OUTPUT))-$(OSVAR).zip
	@cd packages;\
	7z a -r $(subst .exe,,$(OUTPUT))-$(OSVAR).zip $(subst .exe,,$(OUTPUT))-$(OSVAR)
	@rm -rf packages/$(subst .exe,,$(OUTPUT))-$(OSVAR)
endif
	@$(ECHO) Find the built archive under the packages directory.
endif

ifeq ($(HASDEMO),true)
package_demo:
	@$(ECHO) Building demo release package
	@if [ -d distrib ]; then \
	rm -rf distrib;\
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
	$(MAKE) demo;\
	unset LD_RUN_PATH
else
	@for x in $$(ls -1 $(WINDLLDIR));do \
	cp $$x distrib;\
	done
	@$(MAKE) demo
endif
	@cp $(OUTPUT) distrib
	@if [ ! -d packages ];then mkdir packages;fi
ifneq ($(OSVAR),win32)
	@if [ -d packages/$(subst .exe,,$(OUTPUT))-$(OSVAR)-$$(uname -m |tr '_' '-')-full ];then rm -rf packages/$(subst .exe,,$(OUTPUT))-$(OSVAR)-$$(uname -m |tr '_' '-')-full;fi
	@mv distrib packages/$(subst .exe,,$(OUTPUT))-$(OSVAR)-$$(uname -m |tr '_' '-')-full
	@$(RM) packages/$(subst .exe,,$(OUTPUT))-$(OSVAR)-$$(uname -m |tr '_' '-')-full.tar.xz
	@cd packages;\
	tar -cJRf $(subst .exe,,$(OUTPUT))-$(OSVAR)-$$(uname -m |tr '_' '-')-full.tar.xz $(subst .exe,,$(OUTPUT))-$(OSVAR)-$$(uname -m |tr '_' '-')-full
	@rm -rf packages/$(subst .exe,,$(OUTPUT))-$(OSVAR)-$$(uname -m |tr '_' '-')-full
else
	@if [ -d packages/$(subst .exe,,$(OUTPUT))-$(OSVAR)-demo ];then $(RM) -r packages/$(subst .exe,,$(OUTPUT))-$(OSVAR)-demo;fi
	@mv distrib packages/$(subst .exe,,$(OUTPUT))-$(OSVAR)-demo
	@$(RM) packages/$(subst .exe,,$(OUTPUT))-$(OSVAR)-demo.zip
	@cd packages;\
	7z a -r $(subst .exe,,$(OUTPUT))-$(OSVAR)-demo.zip $(subst .exe,,$(OUTPUT))-$(OSVAR)-demo
	@rm -rf packages/$(subst .exe,,$(OUTPUT))-$(OSVAR)-demo
endif
	@$(ECHO) Find the built archive under the packages directory.

package_full:
	@$(ECHO) Building full release package
	@if [ -d distrib ]; then \
	rm -rf distrib;\
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
	$(MAKE) full;\
	unset LD_RUN_PATH
else
	@for x in $$(ls -1 $(WINDLLDIR));do \
	cp $$x distrib;\
	done
	@$(MAKE) full
endif
	@cp $(OUTPUT) distrib
	@if [ ! -d packages ];then mkdir packages;fi
ifneq ($(OSVAR),win32)
	@if [ -d packages/$(subst .exe,,$(OUTPUT))-$(OSVAR)-$$(uname -m |tr '_' '-')-full ];then rm -rf packages/$(subst .exe,,$(OUTPUT))-$(OSVAR)-$$(uname -m |tr '_' '-')-full;fi
	@mv distrib packages/$(subst .exe,,$(OUTPUT))-$(OSVAR)-$$(uname -m |tr '_' '-')-full
	@$(RM) packages/$(subst .exe,,$(OUTPUT))-$(OSVAR)-$$(uname -m |tr '_' '-')-full.tar.xz
	@cd packages;\
	tar -cJRf $(subst .exe,,$(OUTPUT))-$(OSVAR)-$$(uname -m |tr '_' '-')-full.tar.xz $(subst .exe,,$(OUTPUT))-$(OSVAR)-$$(uname -m |tr '_' '-')-full
	@rm -rf packages/$(subst .exe,,$(OUTPUT))-$(OSVAR)-$$(uname -m |tr '_' '-')-full
else
	@if [ -d packages/$(subst .exe,,$(OUTPUT))-$(OSVAR)-full ];then $(RM) -r packages/$(subst .exe,,$(OUTPUT))-$(OSVAR)-full;fi
	@mv distrib packages/$(subst .exe,,$(OUTPUT))-$(OSVAR)-full
	@$(RM) packages/$(subst .exe,,$(OUTPUT))-$(OSVAR)-full.zip
	@cd packages;\
	7z a -r $(subst .exe,,$(OUTPUT))-$(OSVAR)-full.zip $(subst .exe,,$(OUTPUT))-$(OSVAR)-full
	@rm -rf packages/$(subst .exe,,$(OUTPUT))-$(OSVAR)-full
endif
	@$(ECHO) Find the built archive under the packages directory.
endif

packageclean:
	@$(ECHO) Cleaning up packages
	@$(RM) -r packages

fullclean: clean packageclean
