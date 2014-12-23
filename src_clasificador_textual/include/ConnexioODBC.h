/*
 * ConnexioODBC.h
 *
 *  Created on: 30/11/2010
 *      Author: achica
 */

#ifndef CONNEXIOODBC_H_
#define CONNEXIOODBC_H_


#include <windows.h>
#include <iostream>
#include <sql.h>
#include <sqlext.h>


using namespace std;


class ConnexioODBC
{

private:
	bool bConnectat;
	SQLHENV *env;
	SQLHDBC *dbc;
	SQLRETURN retCode;
	SQLCHAR message[1024];

public:
	ConnexioODBC();
	~ConnexioODBC();

	bool Connectar(const string &dsn);
	void Desconnectar();
	void EscriuError();

	SQLHDBC *getDBC();

};


#endif /* CONNEXIOODBC_H_ */
