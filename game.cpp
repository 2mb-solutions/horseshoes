/*
*Horseshoes
By 2MB Solutions: https//2mb.solutions
Released under the MIT License. See license.txt for details.
Billy: https://stormdragon.tk/
Michael: https://michaeltaboada.me
*/
//#define ALLEGRO_STATICLINK 1  
#include <allegro5/allegro.h>
#include "dynamic_menu.h"
#include <keyboard.h>
#include <stdlib.h>
#include <sound.h>
#include <string>
#include <time.h>
#include <iostream>
using namespace std;
#include <menu_helper.h>
#include <misc.h>
#include <soundplayer.h>


void play(int mode, int diff);

int main(int argc, char** argv) {
srand ( time(NULL) ); //initialize the random seed
ALLEGRO_DISPLAY* disp = game_window("Horseshoes");
if(!disp) {
log_close();
	return 1;
}
sound* s = new sound();
if(!s->load("sounds/select.ogg")) {
log("Could not load selection sound.\n");
delete s;
s = NULL;
}
sound* o = new sound();
if(!o->load("sounds/option.ogg")) {
log("Could not load option sound.\n");
delete o;
o = NULL;
}
sound* b = new sound();
if(!b->load("sounds/back.ogg")) {
log("Could not load navigation back sound.\n");
delete b;
b = NULL;
}
sound* m = new sound();
if(!m->load("sounds/music.ogg")) {
log("Could not load menu music.\n");
delete m;
m = NULL;
}
else {
m->set_loop(true);
}
int r;
string mainm[] = {"Play game", "credits", "exit"};
dynamic_menu* mainMenu = create_menu(vector<string>(mainm, mainm+3), vector<string>(0));
mainMenu->set_display(disp);
mainMenu->select = s;
mainMenu->move = o;
string mode[] = {"Player versus computer", "Player versus player", "Computer versus computer", "back to main menu."};
dynamic_menu* modeMenu = create_menu(vector<string>(mode, mode+4), vector<string>(0));
modeMenu->set_display(disp);
modeMenu->select = s;
modeMenu->move = o;
string difficulty[] = {"Easy", "Normal", "Hard", "Alan Francis mode", "Back to main menu"};
dynamic_menu* difficultyMenu = create_menu(vector<string>(difficulty, difficulty+5), vector<string>(0));
difficultyMenu->set_display(disp);
difficultyMenu->select = s;
difficultyMenu->move = o;
do {
if(m) {
m->set_gain(0);
m->play();
}
r = mainMenu->run_extended("", "Use your arrow keys to navigate the menu, and the enter key to select.", 1, true);
if (r == 2)
{
credits(disp, "Horseshoes");
}
if(r == 1) {
int gameMode,gameDifficulty;
int r2 = modeMenu->run_extended("", "", 1, true);
if(r2 == 1 || r2 == 3)
{
int r3 = difficultyMenu->run_extended("", "", 2, true);
if(r2 < 4 && r2 > 0)
gameMode = r2-1;
if (r3 != 5 && r3 != 0 && r3 != -1 && r3 != 4)
{
gameDifficulty = r3*2+3;
if(m) {
fade(m);
}
play(gameMode, gameDifficulty);
}
else if(r3 == 4) {
if(m) {
fade(m);
}
play(gameMode, 19);
}
else {
if(b) {
b->stop();
b->play();
}
}
}
else if(r2 != -1 && r2 != 0 && r2 != 4) {
if(m) {
fade(m);
}
play(r2-1, 0);
}
else {
if(b) {
b->stop();
b->play();
}
}
}
else {
if(b) {
b->stop();
b->play();
}
}
}
while((r >= 1) && (r <= 2));
if(m) {
fade(m);
}
delete difficultyMenu;
delete modeMenu;
delete mainMenu;
if(b)
delete b;
if(s)
delete s;
if(o)
delete o;
if(m)
delete m;
end_game(disp);
return 0;
}

