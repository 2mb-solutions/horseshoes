@echo off
set allegro_ver="5.0.10"
set allegro_link="MT"
cl /O2 /EHsc /MT /Igame-kit/allegro_stuff /Igame-kit/screen-reader /Igame-kit/allegro_stuff/include /Igame-kit game-kit/misc.cpp game-kit/menu_helper.cpp game-kit/soundplayer.cpp play.cpp game.cpp game-kit/allegro_stuff/sound.cpp game-kit/allegro_stuff/keyboard.cpp game-kit/allegro_stuff/dynamic_menu.cpp game-kit/screen-reader/screen_reader.cpp /link /nologo /out:horseshoes.exe /libpath:game-kit/allegro_stuff/win-lib32 /libpath:game-kit/screen-reader dolapi.lib saapi32.lib nvdaControllerClient32.lib allegro_acodec.lib  allegro_audio.lib allegro.lib allegro_ttf.lib allegro_font.lib FLAC.lib opengl32.lib ogg.lib vorbis.lib vorbisfile.lib dumb.lib freetype.lib winmm.lib psapi.lib gdi32.lib
pause