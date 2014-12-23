/*
 * SentenciaODBC.h
 *
 *  Created on: 30/11/2010
 *      Author: achica
 */

#ifndef SENTENCIAODBC_H_
#define SENTENCIAODBC_H_


#include "ConnexioODBC.h"


class SentenciaODBC
{

private:
	bool bReservat;
	SQLHSTMT *stmt;
	SQLRETURN retCode;
	SQLCHAR message[1024];

public:
	SentenciaODBC();
	~SentenciaODBC();

	bool Init(ConnexioODBC &connexio);
	bool Executa(const string &comanda);
	bool FilaSortida();
	long GetColumnaInt(int num);
	double GetColumnaFloat(int num);
	string GetColumnaString(int num);
	void Allibera();

	void EscriuError();

};


#endif /* SENTENCIAODBC_H_ */
