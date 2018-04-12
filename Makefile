# makefile for mine racer and 2MB projects.
# adapted from the aspen mud makefile.
#compiler and project specific variables
OUTPUT=horseshoes

#program defines
MAKE=make -s
RM = rm -f
ECHO = echo
#compiler flags:
#enable if you want to profile.
PROF =
CFLAGS	= -g -std=c++11 -O2 -march=native -Wall -pedantic -Wextra -Wno-unused-variable -Wno-unused-parameter -I/usr/include/speech-dispatcher -I/usr/include -Igame-kit/allegro_stuff -Igame-kit/screen-reader -Igame-kit

#required libraries
LDFLAGS	= -lallegro_audio -lallegro_acodec -lallegro -lallegro_font -lspeechd

#formatting specific flags
FORMATTER = astyle
FORMAT_FLAGS = --style=gnu -Q

	#source files to compile:
# game-kit files, only update if game-kit has been updated.
GK_S_FILES= game-kit/allegro_stuff/sound.cpp game-kit/allegro_stuff/keyboard.cpp game-kit/screen-reader/screen_reader.cpp \
game-kit/allegro_stuff/dynamic_menu.cpp game-kit/menu_helper.cpp game-kit/misc.cpp game-kit/soundplayer.cpp game-kit/allegro_stuff/sound_pool_item.cpp \
game-kit/allegro_stuff/sound_pool.cpp
# regular source files, specific to the game.
S_FILES= play.cpp game.cpp

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

O_FILES += $(patsubst %.cpp,%.o, $(filter %.cpp, $(S_FILES)))
O_FILES += $(patsubst %.cpp,%.o, $(filter %.cpp, $(GK_S_FILES)))

all: $(O_FILES)
	@$(RM) $(OUTPUT)
	@$(ECHO) Linking.
	@$(CXX) $(CFLAGS) -o $(OUTPUT) $(O_FILES) $(LDFLAGS)

%.o: %.cpp
	@$(ECHO) Compiling $<.
	@$(CXX) $(PROF) -c $(CFLAGS) -o $(patsubst %.cpp,%.o, $<) $<

ifeq ($(HASDEMO),true)
$(patsubst %.cpp,%.o,$(DEMO_H_FILES)): demo.h

demo.h:
	@if [ ! -f demo.h ];then $(ECHO) "Demo.h does not exist, setting to default demo contents."; $(ECHO) "$(DEMODEFINE)" > demo.h;fi
endif

clean:
	@$(ECHO) "Cleaning objects and other binary files"
	@$(RM) $(O_FILES)
	@$(RM) $(OUTPUT)

format:
	@$(ECHO) Formatting
	@$(FORMATTER) $(FORMAT_FLAGS) $(S_FILES)
	@find . -name "*.orig" -exec rm -rf {} \;
	@$(ECHO) Done.

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
else
package:
	@$(ECHO) "Building release package";\
libPath=/usr/lib;\
if [ -d distrib ]; then \
	rm -rf distrib;\
	fi;\
	mkdir -p distrib/lib;\
	for x in "$(RESOURCES)";do \
	cp -R $$x distrib;\
done;\
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
	done;\
	export LD_RUN_PATH="\$$ORIGIN/lib/";\
	$(MAKE);\
	unset LD_RUN_PATH;\
	if [ ! -d packages ];then mkdir packages;fi;\
	if [ -d packages/$(OUTPUT)-linux-$$(uname -m |tr '_' '-') ];then rm -rf packages/$(OUTPUT)-linux-$$(uname -m |tr '_' '-');fi;\
	mv distrib packages/$(OUTPUT)-linux-$$(uname -m |tr '_' '-');\
	cd packages;\
	tar -cJRf $(OUTPUT)-linux-$$(uname -m |tr '_' '-').tar.xz $(OUTPUT)-linux-$$(uname -m |tr '_' '-');\
	cd ..;\
	rm -rf packages/$(OUTPUT)-linux-$$(uname -m |tr '_' '-');\
	$(ECHO) "Find the built .tar.xz archive under the packages directory."
endif

ifeq ($(HASDEMO),true)
package_demo:
	@$(ECHO) "Building demo release package";\
libPath=/usr/lib;\
if [ -d distrib ]; then \
	rm -rf distrib;\
	fi;\
	mkdir -p distrib/lib;\
	for x in "$(RESOURCES)";do \
	cp -R $$x distrib;\
done;\
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
	done;\
	export LD_RUN_PATH="\$$ORIGIN/lib/";\
	$(MAKE) demo;\
	unset LD_RUN_PATH;\
	if [ ! -d packages ];then mkdir packages;fi;\
	if [ -d packages/$(OUTPUT)-linux-$$(uname -m |tr '_' '-')-demo ];then rm -rf packages/$(OUTPUT)-linux-$$(uname -m |tr '_' '-')-demo;fi;\
	mv distrib packages/$(OUTPUT)-linux-$$(uname -m |tr '_' '-')-demo;\
	cd packages;\
	tar -cJRf $(OUTPUT)-linux-$$(uname -m |tr '_' '-')-demo.tar.xz $(OUTPUT)-linux-$$(uname -m |tr '_' '-')-demo;\
	cd ..;\
	rm -rf packages/$(OUTPUT)-linux-$$(uname -m |tr '_' '-')-demo;\
	$(ECHO) "Find the built .tar.xz archive under the packages directory."

package_full:
	@$(ECHO) "Building full release package";\
libPath=/usr/lib;\
if [ -d distrib ]; then \
	rm -rf distrib;\
	fi;\
	mkdir -p distrib/lib;\
	for x in "$(RESOURCES)";do \
	cp -R $$x distrib;\
	done;\
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
	done;\
	export LD_RUN_PATH="\$$ORIGIN/lib/";\
	$(MAKE) full;\
	unset LD_RUN_PATH;\
	cp $(OUTPUT) distrib;\
	if [ ! -d packages ];then mkdir packages;fi;\
	if [ -d packages/$(OUTPUT)-linux-$$(uname -m |tr '_' '-')-full ];then rm -rf packages/$(OUTPUT)-linux-$$(uname -m |tr '_' '-')-full;fi;\
	mv distrib packages/$(OUTPUT)-linux-$$(uname -m |tr '_' '-')-full;\
	cd packages;\
	tar -cJRf $(OUTPUT)-linux-$$(uname -m |tr '_' '-')-full.tar.xz $(OUTPUT)-linux-$$(uname -m |tr '_' '-')-full;\
	cd ..;\
	rm -rf packages/$(OUTPUT)-linux-$$(uname -m |tr '_' '-')-full;\
	$(ECHO) "Find the built .tar.xz archive under the packages directory."
endif

packageclean:
	@$(ECHO) "Cleaning up packages"
	@rm -rf packages

fullclean: clean packageclean
