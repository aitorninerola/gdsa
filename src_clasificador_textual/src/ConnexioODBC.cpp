/*
 * ConnexioODBC.cpp
 *
 *  Created on: 30/11/2010
 *      Author: achica
 */

#include <sstream>
#include "..\include\ConnexioODBC.h"


ConnexioODBC::ConnexioODBC()
{
	bConnectat = false;
	env = new SQLHENV;
	dbc = new SQLHDBC;
}

ConnexioODBC::~ConnexioODBC()
{
	if(bConnectat)
		Desconnectar();
	delete env;
	delete dbc;
}

bool ConnexioODBC::Connectar(const string &dsn)
{
	SQLCHAR sqlstate[1024];
	stringstream stream;

	bConnectat = true;
	/* Allocate an environment handle */
	retCode = SQLAllocHandle(SQL_HANDLE_ENV, SQL_NULL_HANDLE, env);
	if(retCode == SQL_ERROR)
	{
		SQLGetDiagRec(SQL_HANDLE_ENV, *env, 1, sqlstate, NULL, message, 1024, NULL);
		return false;
	}
	/* We want ODBC 3 support */
	retCode = SQLSetEnvAttr(*env, SQL_ATTR_ODBC_VERSION, (void *) SQL_OV_ODBC3, 0);
	if(retCode == SQL_ERROR)
	{
		SQLGetDiagRec(SQL_HANDLE_ENV, *env, 1, sqlstate, NULL, message, 1024, NULL);
		return false;
	}
	/* Allocate a connection handle */
	retCode = SQLAllocHandle(SQL_HANDLE_DBC, *env, dbc);
	if(retCode == SQL_ERROR)
	{
		SQLGetDiagRec(SQL_HANDLE_DBC, *dbc, 1, sqlstate, NULL, message, 1024, NULL);
		return false;
	}
	/* Connect to the DSN mydsn */
	/* You will need to change mydsn to one you have created and tested */
	stream << "DSN=" << dsn << ";";
	retCode = SQLDriverConnect(*dbc, NULL, (SQLCHAR*)stream.str().c_str(), SQL_NTS,
					 NULL, 0, NULL, SQL_DRIVER_COMPLETE);
	if(retCode == SQL_ERROR)
	{
		SQLGetDiagRec(SQL_HANDLE_DBC, *dbc, 1, sqlstate, NULL, message, 1024, NULL);
		return false;
	}

	return true;
}

void ConnexioODBC::Desconnectar()
{
	bConnectat = false;
	SQLFreeHandle(SQL_HANDLE_DBC, *dbc);
	SQLFreeHandle(SQL_HANDLE_ENV, *env);  //End the connection
}

void ConnexioODBC::EscriuError()
{
	cout << "Missatge d'error: " << message << endl;
	system("pause");
}

SQLHDBC *ConnexioODBC::getDBC()
{
	return dbc;
}

