#include <iostream>
using namespace std;
#include <cstdlib>
#include<ctime>
#include <string>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <conio.h>
#include <windows.h>
#include <unistd.h>
#include<bits/stdc++.h>

#define MAX_WORDS 1000
#define MAX_LEN 256

int NUM_TRY;
int checkGuess (char, string, string&);
void main_menu();
string message = "Play!";

int hangmanFigure(int wrong_choice)
{
    char head = 'O', left_body = '/', right_body = '\\', body = '|';

    if (wrong_choice >0){
        cout << "\n";
        cout << "+---------+\n";
        cout << "|\t |\n";
        cout << "|\t "<< head << endl;}
    if (wrong_choice == 2)
        cout << "|\t" << body << endl;
    else if (wrong_choice > 2)
        cout << "|\t" << left_body << body ;
    if (wrong_choice > 3)
        cout << right_body << endl;
    if (wrong_choice > 4)
        cout << "|\t" << left_body;
    if (wrong_choice >= 5){
        cout << " " << right_body<< endl;
    cout << "|\t";
    cout << "\n============";}
    return 0;
}
int checkGuess (char guess, string secretmonth, string &guessmonth)
{
	int i;
	int matches=0;
	int len=secretmonth.length();
	for (i = 0; i< len; i++)
	{
		if (guess == guessmonth[i])
			return 0;
		if (guess == secretmonth[i])
		{
			guessmonth[i] = guess;
			matches++;
		}
	}
	return matches;
}

void main_menu()
{
    cout <<"\n\n"<<message<<"\n"<< "\nYou have " << NUM_TRY << " chance(s) to guess the word.";
}
enum IN {
    IN_BACK = 8,
    IN_RET = 13

};
std::string takePasswdFromUser(
    char sp = '*')
{
    string passwd = "";
    char ch_ipt;
    while (true) {
        ch_ipt = getch();
        if (ch_ipt == IN::IN_RET) {
            cout << endl;
            return passwd;
        }
        else if (ch_ipt == IN::IN_BACK && passwd.length() != 0) {
            passwd.pop_back();
            cout << "\b \b";
 
            continue;
        }
        else if (ch_ipt == IN::IN_BACK
                 && passwd.length() == 0) {
            continue;
        }
        passwd.push_back(ch_ipt);
        cout << sp;
    }
}
void Game(string fl,string hide_f){
	char letter;
	int w=0;
				while (NUM_TRY!=0) {
					main_menu();
					cout << "\n\n" << hide_f;
					cout << "\nGuess a letter: ";
					cin >> letter;

					if (checkGuess(letter, fl, hide_f)==0) {
						w++;
						hangmanFigure(w);
						message = "\nIncorrect letter.";
						NUM_TRY = NUM_TRY - 1;

					} else {
						hangmanFigure(w);
						message = "NICE! You guessed a letter";
					}
					if (fl==hide_f) {
						cout<<"\n\nCongratulations! You got it!";
						cout << "\nThe word is : " << fl << endl;
						break;
					}
				}
				if(NUM_TRY == 0) {
					message = "NOOO! You have been hanged!";
					main_menu();
					cout << "\nThe word was : " << fl << endl;
				}
}
int main(int argc, char *argv[])
{
    int play_again=1;
    while (play_again==1){
    NUM_TRY=5;
    message=" ";
    int w=0,fig=7;
    cout<<"HANGMAN GAME\n" ;
	char letter;
	string month,day,z,fl;
	hangmanFigure(fig);
	int ch,cat;
	cout<<"\n\nWHICH LEVEL WOULD YOU LIKE TO PLAY:\n";
	cout<<"\n1: 1-PLAYER\n2: 2-PLAYER\n3: EXIT!";
	cout << "\n\nEnter which level you would like to play: ";
    cin >> ch;
    switch (ch){
    case 1:{
        cout<<"\n1: Months\n2: Weekdays\n3: Zodiac Signs\n4: Exit";
        cout << "\n\nEnter your category: ";
        cin >> cat;
        switch (cat){
           case 1:{
               string months[] =
	{
		"january",
		"february",
		"march",
		"april",
		"may",
		"june",
		"july",
		"august",
		"september",
		"october",
		"november",
		"december"
	};
            int n=rand()% 12;
            month=months[n];
            string hide_m(month.length(),'X');
    		Game(month,hide_m);
               break;}
           case 2:{
               string days[] =
	{
		"monday",
		"tuesday",
		"wednesday",
		"thursday",
		"friday",
		"saturdau",
		"sunday",
	};
               int d=rand()% 7;
            day=days[d];
            string hide_d(day.length(),'X');
            Game(day,hide_d);
               break;}
          case 3:{
              string zod[] =
	{
		"taurus",
		"gemini",
		"aquarius",
		"virgo",
		"leo",
		"pisces",
		"cancer",
		"sagittarius",
		"libra",
		"scorpio",
		"aries",
		"capricorn"
	};
               int zs=rand()% 12;
            z=zod[zs];
            string hide_z(z.length(),'X');
           Game(z,hide_z);
               break;}
          case 4:
            cout << "\nHope to see you again!\n";
            exit(0);
            break;
           default:
               cout << "\nINVALID CHOICE !\n";
               break;}
               break;}
    case 2:{
        cout << "\nPLAYER 1\n";
    string wrd;
    cout << "Write your choice of Word:";
    wrd = takePasswdFromUser();
    transform(wrd.begin(),wrd.end(), wrd.begin(), ::tolower);
    string hide_wrd(wrd.length(),'X');
    Game(wrd,hide_wrd);
		break;}
    case 3:{
        cout << "\nHope to see you again!\n";
        exit(0);
        break;}
    default:
        cout << "\nINVALID CHOICE !\n";
        break;
    }
    cout << "\nWould you like to play again?\n1. Yes\n2. No\n\nEnter your choice: ";
    cin>>play_again;
    cout << "\n";
    switch(play_again){
    case 1:{
            NUM_TRY=5;
            continue;}
    case 2:{
        play_again=2;
        cout << "\nHope to see you again!\n";
        exit(0);
        break;
        }
    default:{
        cout << "\nINVALID CHOICE !\n";
        continue;
    }}}
	return 0;
}
