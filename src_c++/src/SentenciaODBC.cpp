/*
 * SentenciaODBC.cpp
 *
 *  Created on: 30/11/2010
 *      Author: achica
 */

#include "..\include\SentenciaODBC.h"


SentenciaODBC::SentenciaODBC()
{
	bReservat = false;
	stmt = new SQLHSTMT;
}

SentenciaODBC::~SentenciaODBC()
{
	if(bReservat)
		Allibera();
	delete stmt;
}

bool SentenciaODBC::Init(ConnexioODBC &connexio)
{
	SQLCHAR sqlstate[1024];

	/* Allocate a statement handle */
	retCode = SQLAllocHandle(SQL_HANDLE_STMT, *connexio.getDBC(), stmt);
	if(retCode == SQL_ERROR)
	{
		SQLGetDiagRec(SQL_HANDLE_STMT, *stmt, 1, sqlstate, NULL, message, 1024, NULL);
		return false;
	}

	return true;
}

bool SentenciaODBC::Executa(const string &comanda)
{
	SQLCHAR sqlstate[1024];

	retCode = SQLExecDirect(*stmt, (SQLCHAR*)comanda.c_str(), SQL_NTS);
	if(retCode == SQL_ERROR)
	{
		SQLGetDiagRec(SQL_HANDLE_STMT, *stmt, 1, sqlstate, NULL, message, 1024, NULL);
		return false;
	}

	return true;
}

bool SentenciaODBC::FilaSortida()
{
	return SQL_SUCCEEDED(SQLFetch(*stmt));
}

long SentenciaODBC::GetColumnaInt(int num)
{
	long retVal, cbData;

	SQLGetData(*stmt,num,SQL_C_SLONG,&retVal,256,&cbData);

	return retVal;
}

double SentenciaODBC::GetColumnaFloat(int num)
{
	long cbData;
	double retVal;

	SQLGetData(*stmt,num,SQL_C_DOUBLE,&retVal,256,&cbData);

	return retVal;
}

string SentenciaODBC::GetColumnaString(int num)
{
	long cbData;
	char retVal[256];
	string str;

	SQLGetData(*stmt,num,SQL_C_CHAR,retVal,256,&cbData);
	str = string(retVal);

	return str;
}

void SentenciaODBC::Allibera()
{
	bReservat = false;
	SQLFreeHandle(SQL_HANDLE_STMT, stmt);
}

void SentenciaODBC::EscriuError()
{
	cout << "Missatge d'error: " << message << endl;
	system("pause");
}

