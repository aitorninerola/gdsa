//https://www.youtube.com/watch?v=Z1g-NgT8WoM


#include <iostream>
#include <stdlib.h>
#include <fstream>
#include <sstream>
#include <vector>
#include <map>
using namespace std;
int main (void)
{
    map<string, vector<string> > M;
    vector<string> TAGS;
    ifstream F;
    string idimg, tag;// int i =0;
    F.open ("sed2013_task2_dataset_train_tags.csv");
    F>>idimg; F>>tag;
    if (F.is_open()) {
        while (!F.eof()) {
            while (F>>idimg && F>>tag){
                   M[idimg].push_back (tag);

            }
        }
    }
     else {
        cout << "no se ha abierto" << endl;
    }
    ofstream E("tags_por_comas_todos.csv");
    map<string, vector<string> >::iterator it;
    for (it=M.begin(); it!=M.end(); it++){
        E<< it->first;
        for (int j=0; j< it->second.size(); j++) E<<';'<<it->second[j];
        E<< endl;
    }
    F.close();
}
//3.766s
