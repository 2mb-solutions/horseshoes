#!/bin/bash

#export LD_RUN_PATH='$ORIGIN/lib/'
#if [ $# -eq 0 ]; then
#g++ -static-libgcc -static-libstdc++ -O3 -I/usr/include/speech-dispatcher -I/usr/include -Igame-kit/allegro_stuff -Igame-kit/screen-reader -Igame-kit game-kit/allegro_stuff/sound.cpp game-kit/allegro_stuff/keyboard.cpp game-kit/screen-reader/screen_reader.cpp game-kit/allegro_stuff/dynamic_menu.cpp game-kit/menu_helper.cpp game-kit/misc.cpp game-kit/soundplayer.cpp play.cpp game.cpp -lallegro_ttf -lallegro_audio -lallegro_acodec -lallegro -lallegro_font -lspeechd -logg -lvorbis -lvorbisfile && mv a.out horseshoes
#else
#g++ -static-libgcc -static-libstdc++ -m32 -O3 -I/usr/include/speech-dispatcher -I/usr/include -Igame-kit/allegro_stuff -Igame-kit/screen-reader -Igame-kit game-kit/allegro_stuff/sound.cpp game-kit/allegro_stuff/keyboard.cpp game-kit/screen-reader/screen_reader.cpp game-kit/allegro_stuff/dynamic_menu.cpp game-kit/menu_helper.cpp game-kit/misc.cpp game-kit/soundplayer.cpp play.cpp game.cpp -lallegro_ttf -lallegro_audio -lallegro_acodec -lallegro -lallegro_font -lspeechd -logg -lvorbis -lvorbisfile && mv a.out horseshoes
#fi
#unset LD_RUN_PATH
#if [ $# -eq 0 ]; then
g++ -O3 -I/usr/include/speech-dispatcher -I/usr/include -Igame-kit/allegro_stuff -Igame-kit/screen-reader -Igame-kit game-kit/allegro_stuff/sound.cpp game-kit/allegro_stuff/keyboard.cpp game-kit/screen-reader/screen_reader.cpp game-kit/allegro_stuff/dynamic_menu.cpp game-kit/menu_helper.cpp game-kit/misc.cpp game-kit/soundplayer.cpp play.cpp game.cpp -lallegro_ttf -lallegro_audio -lallegro_acodec -lallegro -lallegro_font -lspeechd -logg -lvorbis -lvorbisfile && mv a.out horseshoes
#else
#g++ -m32 -O3 -L/usr/lib32 -I/usr/include/speech-dispatcher -I/usr/include -Igame-kit/allegro_stuff -Igame-kit/screen-reader -Igame-kit game-kit/allegro_stuff/sound.cpp game-kit/allegro_stuff/keyboard.cpp game-kit/screen-reader/screen_reader.cpp game-kit/allegro_stuff/dynamic_menu.cpp game-kit/menu_helper.cpp game-kit/misc.cpp game-kit/soundplayer.cpp play.cpp game.cpp -lallegro_ttf -lallegro_audio -lallegro_acodec -lallegro -lallegro_font -lspeechd -logg -lvorbis -lvorbisfile && mv a.out horseshoes
#fi
exit 0
