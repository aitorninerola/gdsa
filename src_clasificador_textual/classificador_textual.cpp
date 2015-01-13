/*
Copyright 2015 Aitor Niñerola, Eduardo Bernal, Luís Varas, Mohamed el Bouchti


    This file is part of SocialEventDetector

    SocialEventDetector is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    Foobar is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with SocialEventDetector.  If not, see <http://www.gnu.org/licenses/
*/
#include <iostream>
#include <iomanip>
#include <sstream>
#include <fstream>
#include <ctime>
#include <stdio.h>

//wrapper
#include "include\ConnexioODBC.h"
#include "include\SentenciaODBC.h"
#include<map>

using namespace std;

struct img{
    string tags;
    string user; //username
    string data; //tags
    string coord; //latitude_longitude
    string clase; //event_type
};

double temps(clock_t inici){
    clock_t endTime = clock();
    clock_t clockTicksTaken = endTime - inici;
    return clockTicksTaken / (double) CLOCKS_PER_SEC;
}

void head(string titol){
    cout << endl
         << "----------------------------------" << endl
         << " " << titol << endl
         << "----------------------------------" << endl;
}

string getdata(string datetime){
    int pos = datetime.find(' ');
    return datetime.substr(0,pos);
}

string joincoord(double latitude, double longitude){
    ostringstream O;
    O << setiosflags(ios::fixed) << setprecision(3) << latitude << '_' << longitude;
    string coord = O.str();
    coord = (coord == "0.000_0.000") ? "NULL" : '"'+coord+'"';
    return coord;
}

void db_insert(img imatge, string &val, string id){
  val = ("('"+id+"', 'u_"+imatge.user+"', '"+imatge.tags+"',"+imatge.coord+", '"+imatge.data+"', '"+imatge.clase+"')");
}

string db_search(img imatge){
     return ("u_"+imatge.user+" "+imatge.tags+" "+(imatge.coord).substr(1,imatge.coord.size()-2)+" "+imatge.data);
}

string separa(string fitxer){
    string id, out;
    ifstream F(fitxer.c_str());
    while(getline(F,id)){
        out += ('"'+id+'"'+",");
    }
    return '('+out.substr(0,out.size()-1)+')';
}

void create_trainset(ConnexioODBC &conn){
    head("TRAIN SET");
    ostringstream O;
    SentenciaODBC s;
    clock_t t,ti;
    ti = clock();
    string id, tag, row, val, fitxer, in;
    double lat, lon;
    map<string, img> trainset;
    map<string, img>::iterator it;

    //cout << "Nom del fitxer que conte el llistat d'imatges d'entrenament: "; cin >> fitxer;
    fitxer = "trainset.txt";

    in = separa(fitxer);
    O << "SELECT D.document_id, D.username, D.date_taken, D.latitude, D.longitude, C.event_type from gdsa_datainfo D JOIN gdsa_classified C ON D.document_id = C.document_id WHERE D.document_id IN " << in << ";";
    s.Init(conn);
    t = clock();
    cout << "Obtaining images info..." << endl;
    if(!s.Executa(O.str())) s.EscriuError();
    cout << "Metadata retrieved properly: "<<temps(t) <<"s. Saving data..." << endl;
    t = clock();
    while(s.FilaSortida()){

        img pic;
        pic.user = s.GetColumnaString(2);
        pic.data = getdata(s.GetColumnaString(3));
        pic.clase = s.GetColumnaString(6);
        lat = s.GetColumnaFloat(4);
        lon = s.GetColumnaFloat(5);
        pic.coord = joincoord(s.GetColumnaFloat(4),s.GetColumnaFloat(5));
        trainset[s.GetColumnaString(1)] = pic;

	}
	s.Allibera();
	cout << "Metadata saved: "<<temps(t) <<"s. " << endl;

   t = clock();
    head("Obtaining tags...");
     O.str("");
    O << "SELECT document_id, tag from gdsa_tags WHERE document_id IN " << in << ";";
    if(!s.Executa(O.str())) s.EscriuError();
    cout << "Tags retrieved properly: "<<temps(t) <<"s. Saving data..." << endl;
    t = clock();
    while(s.FilaSortida()){
        trainset[s.GetColumnaString(1)].tags += (' '+ s.GetColumnaString(2));
	}
	s.Allibera();

    cout << "Tags saved: "<<temps(t) <<"s." << endl;
    t = clock();
    head("Training system...");
    string sql = "CREATE TABLE IF NOT EXISTS trainset(document_id VARCHAR(255) NOT NULL PRIMARY KEY,user varchar(255),tags TEXT,coord varchar(255),data varchar(355),classe VARCHAR(20),FULLTEXT (user,tags,coord,data)) ENGINE=InnoDB;";
    if(!s.Executa(sql)) s.EscriuError();

    sql = "TRUNCATE TABLE trainset;";
    if(!s.Executa(sql)) s.EscriuError();


    for(it = trainset.begin(); it != trainset.end(); ++it){
        db_insert(it->second,val,it->first);
        O.str("");
        O << "INSERT INTO trainset VALUES " << val << ";";
        if(!s.Executa(O.str())) s.EscriuError();
    }
    cout << "System trained: "<<temps(t) <<"s." << endl;




	cout << endl << "Total time for training: " << temps(ti) << "s." << endl;

}

void create_testset(ConnexioODBC &conn){
    head("TEST SET");
    ostringstream O;
    SentenciaODBC s;
    clock_t t,ti;
    ti = clock();
    string id, tag, row, val, fitxer, in;
    double lat, lon;
    map<string, img> testset;
    map<string, img>::iterator it;
    ofstream FO("results_textual.txt");

    //cout << "Nom del fitxer que conte el llistat d'imatges a classificar: "; cin >> fitxer;

    fitxer = "testset.txt";

    t = clock();
    in = separa(fitxer);
    O << "SELECT D.document_id, D.username, D.date_taken, D.latitude, D.longitude FROM gdsa_datainfo D WHERE D.document_id IN " << in << ";";

    s.Init(conn);

    cout << "Obtaining images info..." << endl;
    t = clock();
    if(!s.Executa(O.str())) s.EscriuError();
    cout << "Metadata retrieved properly: "<<temps(t) <<"s. Saving data..." << endl;
    t = clock();
    while(s.FilaSortida()){

        img pic;
        pic.user = s.GetColumnaString(2);
        pic.data = getdata(s.GetColumnaString(3));
        lat = s.GetColumnaFloat(4);
        lon = s.GetColumnaFloat(5);
        pic.coord = joincoord(s.GetColumnaFloat(4),s.GetColumnaFloat(5));
        testset[s.GetColumnaString(1)] = pic;

	}
	s.Allibera();
	cout << "Test files info saved: "<<temps(t) <<"s. " << endl;

    t = clock();
    head("Obtaining tags...");
     O.str("");
    O << "SELECT document_id, tag from gdsa_tags WHERE document_id IN " << in << ";";
    if(!s.Executa(O.str())) s.EscriuError();
    cout << "Tags retrieved properly: "<<temps(t) <<"s. Saving data..." << endl;
    t = clock();
    while(s.FilaSortida()){
        testset[s.GetColumnaString(1)].tags += (' '+ s.GetColumnaString(2));
	}
	s.Allibera();

    cout << "Tags saved: "<<temps(t) <<"s." << endl;
    t = clock();
    head("Runnin classification...");

    for(it = testset.begin(); it != testset.end(); it++){
        O.str("");
        O << "SELECT classe, MATCH (user,tags,coord,data)  AGAINST (\"" << db_search(it->second) << "\" in boolean mode) as score FROM trainset  having score > 0 ORDER BY score DESC LIMIT 1;";
        if(!s.Executa(O.str())) s.EscriuError();
        while(s.FilaSortida()){
        (it->second).clase = s.GetColumnaString(1);
        FO << it->first << ' ' << (it->second).clase << '\n';
	}

    }
    cout << "Images classified. Time elapsed: "<<temps(t) <<"s." << endl;
    FO.close();
	cout << endl << "Total time elapsed for classify test images: " << temps(ti) << "s." << endl;

}


int main(){
    ConnexioODBC conn;
    clock_t t;
    t = clock();
    head("Connecting database...");
    cout << "Connected. Time elapsed: "<<temps(t) << "s."<< endl;
    conn.Connectar("mediaeval");

    create_trainset(conn);
    create_testset(conn);
    conn.Desconnectar();
}
