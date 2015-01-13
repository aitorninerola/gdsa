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

string separa(string fitxer, map<string,string> & etiqueta){
    string row, out, id, clas;
    ifstream F(fitxer.c_str());
    while(getline(F,row)){
        istringstream I(row);
        I >> id >> clas;
        etiqueta[id] = clas;
        out += ('"'+id+'"'+",");
    }
    return '('+out.substr(0,out.size()-1)+')';
}

double calc_precision(int T[9][9], int n){
    double sum = 0,val = T[n][n];
    for(int i = 0; i < 9; i++){
        sum += T[i][n];
    }

    if(sum == 0.0) return 0.0;
    else return val/sum;
}

double calc_recall(int T[9][9], int n){
    double sum = 0,val = T[n][n];
    for(int i = 0; i < 9; i++){
        sum += T[n][i];
    }

    if(sum == 0.0) return 0.0;
    else return val/sum;
}

double calc_accuracy(int T[9][9]){
    double diag = 0, sum = 0;
    for(int i = 0; i<9; i++){
        for(int j=0; j<9; j++){
            if(i==j) diag += T[i][j];
            sum += T[i][j];
        }
    }
    if(sum == 0.0) return 0;
    else return (diag/sum);
}


int main(){
    ConnexioODBC conn;
    clock_t t,ti;
    t = clock();
    head("Connecting database...");
    cout << "Connected: "<<temps(t) << "s."<< endl;
    conn.Connectar("mediaeval");
    ofstream RES("evaluation_results.txt");

    head("Evaluating results...");

    ti = clock();
    string id, tag, row, val, fitxer, fitxer2, in, v_clas, v_etiq;
    map<string,int> classes;
    map<string, string>::iterator it;
    map<string,int>::iterator it2;


    classes["concert"]= 0;
    classes["conference"] = 1;
    classes["exhibition"] = 2;
    classes["fashion"] = 3;
    classes["non_event"] = 4;
    classes["other"] = 5;
    classes["protest"] = 6;
    classes["sports"] = 7;
    classes["theater_dance"] = 8;

    int nfil;
    cout << "Number of result files: "; cin >> nfil;

    for(int i= 0; i<nfil; i++){
    ostringstream O;
    SentenciaODBC s;

        cout << "Results file in results/FILENAME: "; cin >> fitxer;
        fitxer2 = fitxer;
        fitxer = "results/"+fitxer;
        ti = clock();
        string confile = "confmat_"+fitxer2+".csv";
        //ofstream FO(confile.c_str());

        map<string, string> clase,etiqueta;
        map<string, double> precision, recall, f1score;
        double av_f1score = 0;


        t = clock();
        in = separa(fitxer,etiqueta);
        O << "SELECT D.document_id, D.event_type FROM gdsa_classified D WHERE D.document_id IN " << in << ";";

        s.Init(conn);

        cout << "Getting real classes..." << endl;
        t = clock();
        if(!s.Executa(O.str())) s.EscriuError();
        cout << "Data retrieved correctly: "<<temps(t) <<"s. Saving data..." << endl;
        t = clock();
        while(s.FilaSortida()){
            clase[s.GetColumnaString(1)] = s.GetColumnaString(2);
        }
        s.Allibera();
        cout << "Data saved properly: "<<temps(t) <<"s. " << endl;

        t = clock();
        head("Calculating results...");
        int sa = clase.size();
        int sb = etiqueta.size();
        int nfila, ncol, confmat[9][9];

        for(int i = 0; i< 9; i++){
            for(int j=0; j < 9; j++){
                confmat[i][j] = 0;
            }
        }

        if(sa != sb) {
            cout << "DIMENSIONS MISMATCH" << endl;
            return 1;
        } else{
            for(it=clase.begin();it!=clase.end();it++){
                id = it->first;
                v_clas = it->second;
                v_etiq = (etiqueta.find(it->first))->second;
                it2 = classes.find(v_clas);
                nfila = it2->second;
                it2 = classes.find(v_etiq);
                ncol = it2->second;
                confmat[nfila][ncol]++;
            }
        }

        //calcul de la precisio, record i f1 score
        cout << "Calculating precision, recall and f1 score" << endl;
        for(it2 = classes.begin(); it2 != classes.end(); it2++){
            int id_c = it2->second;
            string n_cl = (it2->first).c_str();
            precision[n_cl] = calc_precision(confmat,id_c);
            recall[n_cl] = calc_recall(confmat, id_c);
            if((precision[n_cl]+recall[n_cl]) == 0.0) f1score[n_cl] = 0.0;
            else f1score[n_cl] = 2.0*((precision[n_cl]*recall[n_cl])/(precision[n_cl]+recall[n_cl]));
        }

        cout << "Calculating averages" << endl;
        for(it2 = classes.begin(); it2!= classes.end(); it2++){
            string n_cl = (it2->first).c_str();
            av_f1score+=f1score[n_cl];
        }
        av_f1score = av_f1score/9.0;

        RES << "----------------------------------------"<<endl
            << "Results for: " << fitxer << endl
            << endl
            << "Accuracy: " << calc_accuracy(confmat) << endl
            << "F1-score: " << av_f1score << endl
            << "----------------------------------------"<<endl;

    /*
        for(int i = 0; i< 9; i++){
            for(int j=0; j < 9; j++){
                FO << confmat[i][j] << ';';
            }
            FO << endl;
        }
        */

        cout << "Results saved: "<<temps(t) <<"s." << endl;
        //FO.close();
        cout << endl << "TOTAL time elapsed for evaluation: " << temps(ti) << "s." << endl;
    }
    RES.close();
    conn.Desconnectar();
}
