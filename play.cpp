/*
*Horseshoes
By 2MB Solutions: https//2mb.solutions
Released under the terms of the unlicense: http://unlicense.org
Billy: https://stormdragon.tk/
Michael: https://michaeltaboada.me
*/
#define ALLEGRO_STATICLINK 1
#include <screen_reader.h>
#include <allegro5/allegro.h>
#include <sound.h>
#include <keyboard.h>
#include <stdlib.h>
#include <sstream>
using std::stringstream;
#include <soundplayer.h>
#include <misc.h>

void play_throw(int p, int d);
void play_score(int sc, int p, int d, int score0, int score1);
int do_computer_power(int p);
int do_computer_direction(int d);


void play(int mode, int diff)
{
sound back;
if(!back.load("sounds/background.ogg")) {
log("Could not load background sounds.\n");
}
else {
back.set_loop(true);
if(!back.play()) {
log("Could not play background sounds.\n");
}
}
int playerScore [2] = {0,0};
string playerName [2];
int turn = 0;
//player2 enters name here.
screen_reader sr;
keyboard kb;
string s="";
if(mode == 1 || mode == 0) {
do {
sr.speak_any_interrupt("Player 1, please enter your name, then press enter.");
s = kb.get_chars();
} while(s.compare("") == 0);
playerName[0] = s;
}
else if(mode == 2) {
playerName[0] = get_cpu_name();
}
if(mode == 0 || mode == 2)
{
if (diff == 19)
{
playerName[1] = "Alan";
}
else
{
do
{
playerName[1] = get_cpu_name();
}
while (playerName[0] == playerName[1]);
}
}
else if(mode == 1) {
do {
sr.speak_any_interrupt("Player 2, please enter your name, then press enter.");
s = kb.get_chars();
} while(s.compare("") == 0);
playerName[1] = s;
}
sr.speak_any(playerName[0]+(string)(" verses ")+playerName[1]+(string)("!"));
while ((playerScore[0] < 15) && (playerScore[1] < 15))
{
int power,direction;
if((turn == 1 && mode == 0) || (mode == 2)) {
sr.speak_any(playerName[turn]+" Is up to throw.");
al_rest(0.75);
power = do_computer_power(diff);
direction = do_computer_direction(diff);
}
else {
sr.speak_any(playerName[turn] + " is up to throw.");
do {
if(kb.key_pressed(ALLEGRO_KEY_ESCAPE)) {
return;
}
al_rest(0.005);
} while(!kb.key_pressed(ALLEGRO_KEY_SPACE));
power = power_bar("sounds/power.ogg");
direction = direction_bar("sounds/direction.ogg");
}
if(direction == -100 || power == -100) {
return;
}
play_throw(power, direction);
int sc = 0;
if ((direction > -10) && (direction < 10))
{
if (power >= 159 && (power <= 165))
{
playerScore[turn] += 3;
sr.speak_any(playerName[turn] + " got a ringer! three points!");
sc = 3;
}
else if ((power >= 153) && (power <= 171))
{
playerScore[turn]++;
sr.speak_any(playerName[turn] + " scored one point.");
sc = 1;
}
}
else
{
if (direction <= -10)
{
sr.speak_any(playerName[turn] + " threw off to the left.");
}
else if (direction >= 10)
{
sr.speak_any(playerName[turn] + " threw off to the right.");
}
}
if (power <= 152)
{
sr.speak_any(playerName[turn] + " threw short.");
}
else if (power >= 172)
{
sr.speak_any(playerName[turn] + " threw long.");
}
play_score(sc, power, direction, playerScore[0], playerScore[1]);
stringstream s;
s << playerName[0] << ": " << playerScore[0] << ". " << playerName[1] << ": " << playerScore[1] << ".";
sr.speak_any(s.str());
turn = (turn == 1)?0:1;
}
turn = ((turn == 0)?1:0);
stringstream st;
st << playerName[turn] << "Has won the game with a score of " << playerScore[turn] << " to " << playerScore[((turn == 1)?0:1)] << "!";
sr.speak_any(st.str());
play_score(15, 0, 0, 0, 0);
back.stop();
}

void play_throw(int p, int d) {
sound s;
if(!s.load("sounds/throw.ogg")) {
log("Could not load throw sound.\n");
}
/*
int dir = 0;
if(d < -7 && d >= -15) {
dir = -1;
}
else if(d < -15 && d > -25) {
dir = -2;
}
else if(d < -25 && d > -35) {
dir = -3;
}
else if(d < -35 && d >-45) {
dir = -4;
}
else if( d <= -45) {
dir = -5;
}
else if(d > 7 && d < 15) {
dir = 1;
}
else if(d > 15 && d < 25) {
dir = 2;
}
else if(d > 25 && d < 35) {
dir = 3;
}
else if(d > 35 && d < 45) {
dir = 4;
}
else if(d >= 45) {
dir = 5;
}
int pow = -25;
if(p < 160) {
pow = -15;
}
else if(p > 168) {
pow = -35;
}
*/
int dir = d/10;
int pow = p/-20;
for(int x = 0; x >= pow; x--) {
if(!s.play()) {
log("Could not play throw sound.\n");
}
while(s.is_playing()) {
al_rest(0.001);
}
s.set_gain(x);
s.set_pan(s.get_pan()+dir);
}
}

void play_score(int sc, int p, int d, int score0, int score1) {
sound s;
sound s2;
if(sc == 3) {
if(!play_sound_wait("sounds/ringer.ogg")) {
log("Could not play ringer sound.\n");
}
}
else if (sc == 1) {
if(!play_sound_wait("sounds/point.ogg")) {
log("Could not play point sound.\n");
}
}
else if (sc == 0) {
stringstream st;
st << "sounds/gasp" << rand()%2 << ".ogg";
s2.load(st.str());
s.load("sounds/miss.ogg");
s.set_gain(p/-20);
s.set_pan((p/20)*(d/10));
}
else if(sc == 15) {
if(!play_sound_wait("sounds/win.ogg")) {
log("Could not play win sound.\n");
}
}
if(sc == 0 && (score1-score0 <= 3 && score1-score0 >= -3)) {
if(!s.play()) {
log("Could not play miss sound.\n");
}
if(!s2.play()) {
log("Could not play crowd sound.\n");
}
}
while(s.is_playing() || (sc == 0 && s2.is_playing())) {
al_rest(0.005);
}
}

int do_computer_power(int diff) {
int r = rand() % 20 / diff;
if(r == 0) {
return power_bar("sounds/power.ogg", rand()%7 + 159);
}
else if(r == 1) {
int s = rand()%2*2-1;
return power_bar("sounds/power.ogg", 162+((rand()%4+4)*s));
}
else {
int s = rand()%151+50;
return power_bar("sounds/power.ogg", s);}
}

int do_computer_direction(int diff) {
int r = rand()%20/diff;
if(r < 2) {
return direction_bar("sounds/direction.ogg", rand()%19-9);
}
else {
return direction_bar("sounds/direction.ogg", rand()%101-50);
}
}
