/*
 * serial.c
 *
 *  Created on: 21/10/2012
 *      Author: Felipe Michels Fontoura
 */

#include "serial.h"
#include "macros.h"

#include <stdint.h>

rs232_iterator_ptr __INTERNAL__RS232_LINKED_LIST_FIRST = NULL;
rs232_iterator_ptr __INTERNAL__RS232_LINKED_LIST_LAST = NULL;

#define rs232_list_first __INTERNAL__RS232_LINKED_LIST_FIRST
#define rs232_list_last __INTERNAL__RS232_LINKED_LIST_LAST

#ifdef _WIN32

/* implementacao em Windows. */

#include <windows.h>
#include <setupapi.h>

int rs232_init()
{
	rs232_list_first = NULL;
	rs232_list_last = NULL;
	return 0;
}

void rs232_finalize()
{
	while (rs232_list_first != NULL) {
		rs232_list_last = rs232_list_first->next;
		free(rs232_list_first->port);
		free(rs232_list_first);
		rs232_list_first = rs232_list_last;
	}
}

void rs232_refreshPorts()
{
	/* obtem o GUID das portas. */
	GUID guid_ports;
	DWORD requiredSize;
	BOOL result = SetupDiClassGuidsFromName("PORTS", &guid_ports, 1, &requiredSize);
	if (result == FALSE) return;

	/* obtem um handle para as informacoes sobre os dispositivos com este GUID. */
	HDEVINFO info_devices = SetupDiGetClassDevs(&guid_ports, NULL, NULL, DIGCF_PRESENT | DIGCF_PROFILE);
	if (info_devices == INVALID_HANDLE_VALUE) return;

	/* cria a estrutura que recebe informacoes sobre cada dispositivo. */
	SP_DEVINFO_DATA data_device;
	data_device.cbSize = sizeof(SP_DEVINFO_DATA);

	/* variavel na qual o nome da porta e o nome amigavel são salvos. */
	char buffer[MAX_PATH];

	/* marca todos os dispositivos anteriores como invalidos. */
	rs232_iterator_ptr node = rs232_list_first;
	while (node != NULL)
	{
		node->valid = 0;
		node = node->next;
	}

	/* itera sobre o conjunto de dispositivos. */
	int i;
	for (i = 0; SetupDiEnumDeviceInfo(info_devices, i, &data_device) == TRUE; i++)
	{
		/* obtem o nome interno */
		HKEY key = SetupDiOpenDevRegKey(info_devices, &data_device, DICS_FLAG_GLOBAL, 0, DIREG_DEV, KEY_READ);
		if (key != INVALID_HANDLE_VALUE)
		{
			requiredSize = MAX_PATH;
			result = RegQueryValueExA(key, "PortName", NULL, NULL, buffer, &requiredSize);
			char* port;
			if (result == ERROR_SUCCESS)
			{
				/* procura a porta nas portas existentes */
				node = rs232_list_first;
				while (node != NULL)
				{
					if (strcmp(buffer, node->port) == 0)
					{
						break;
					}
					node = node->next;
				}

				/* se achou a porta, marca como valida e continua iterando. */
				if (node != NULL)
				{
					node->valid = -1;
					continue;
				}

				/* aloca a memoria e copia o nome da porta. */
				port = (char*)malloc(requiredSize);
				memcpy(port, buffer, requiredSize);

				/* cria o no da lista. */
				rs232_iterator_ptr node = new(rs232_iterator_t);
				node->port = port;
				node->valid = -1;
				node->next = NULL;

				/* adiciona o no a lista. */
				if (rs232_list_last == NULL)
				{
					rs232_list_first = node;
					rs232_list_last = node;
				}
				else
				{
					rs232_list_last->next = node;
					rs232_list_last = node;
				}

				/* obtem o nome amigavel. */
				/*
				DWORD propertyType;
				result = SetupDiGetDeviceRegistryPropertyA(info_devices, &data_device, SPDRP_FRIENDLYNAME, &propertyType, buffer, sizeof(buffer), &requiredSize);
				if (result == TRUE)
				{
					char* friendlyName = (char*)malloc(requiredSize);
					memcpy(friendlyName, buffer, requiredSize);
				}
				*/
			}
			RegCloseKey(key);
		}
	}
	SetupDiDestroyDeviceInfoList(info_devices);
}

void rs232_iterate(rs232_iterator_ptr* iterator)
{
	*iterator = rs232_list_first;
}

int rs232_conn_open(rs232_conn_ptr* conn, char* port, int baudRate, int byteSize, rs232_stopBits stopBits, rs232_parity parity)
{
	BOOL result;

	/* tenta criar a conexao com a porta serial. */
	HANDLE handle = CreateFileA(port, GENERIC_READ | GENERIC_WRITE, 0, NULL, OPEN_EXISTING, 0, NULL);
	if (handle == INVALID_HANDLE_VALUE) return -1;

	/* tenta definir o baud rate. */
	DCB dcb;
	FillMemory(&dcb, sizeof(dcb), 0);
	result = GetCommState(handle, &dcb);
	if (result == 0)
	{
		CloseHandle(handle);
		return -1;
	}
	dcb.BaudRate = baudRate;
	dcb.ByteSize = byteSize;
	switch (stopBits)
	{
	case RS232_STOPBITS_ONE_DOT_FIVE:
		dcb.StopBits = ONE5STOPBITS;
		break;
	case RS232_STOPBITS_TWO:
		dcb.StopBits = TWOSTOPBITS;
		break;
	default:
		dcb.StopBits = ONESTOPBIT;
		break;
	}
	switch (parity)
	{
	case RS232_PARITY_EVEN:
		dcb.Parity = EVENPARITY;
		break;
	case RS232_PARITY_ODD:
		dcb.Parity = ODDPARITY;
		break;
	default:
		dcb.Parity = NOPARITY;
		break;
	}
	result = SetCommState(handle, &dcb);
	if (result == 0)
	{
		CloseHandle(handle);
		return -1;
	}

	/* tenta definir os timeouts. */
	COMMTIMEOUTS timeouts;
	timeouts.ReadIntervalTimeout = 0;
	timeouts.ReadTotalTimeoutMultiplier = 0;
	timeouts.ReadTotalTimeoutConstant = 0;
	timeouts.WriteTotalTimeoutMultiplier = 0;
	timeouts.WriteTotalTimeoutConstant = 0;
	result = SetCommTimeouts(handle, &timeouts);
	if (result == 0)
	{
		CloseHandle(handle);
		return -1;
	}

	/* cria a estrutura com os dados. */
	rs232_conn_ptr rs232_c = new(rs232_conn_t);
	rs232_c->baudRate = baudRate;
	rs232_c->byteSize = byteSize;
	rs232_c->stopBits = stopBits;
	rs232_c->parity = parity;
	rs232_c->absoluteTimeout = 0;
	rs232_c->relativeTimeout = 0;
	rs232_c->_win32_handle = handle;
	*conn = rs232_c;
	return 0;
}

/* configura os timeouts da conexao com uma porta RS232. */
int rs232_conn_configureTimeouts(rs232_conn_ptr conn, int absolute, int relative)
{
	if (conn == NULL) return 0;
	if (conn->_win32_handle == INVALID_HANDLE_VALUE) return 0;

	/* tenta definir os timeouts. */
	COMMTIMEOUTS timeouts;
	timeouts.ReadIntervalTimeout = 0;
	timeouts.ReadTotalTimeoutMultiplier = relative;
	timeouts.ReadTotalTimeoutConstant = absolute;
	timeouts.WriteTotalTimeoutMultiplier = 0;
	timeouts.WriteTotalTimeoutConstant = 0;
	BOOL result = SetCommTimeouts(conn->_win32_handle, &timeouts);
	if (result == 0) return -1;
	else return 0;
}

/* le um bloco de bytes de uma conexao com porta RS232. */
int rs232_conn_read(rs232_conn_ptr conn, uint8_t* buffer, int length)
{
	if (conn == NULL) return 0;
	if (conn->_win32_handle == INVALID_HANDLE_VALUE) return 0;
	DWORD count = length;
	BOOL result = ReadFile(conn->_win32_handle, buffer, length, &count, NULL);
	if (result == 0) return 0;
	return count;
}

/* escreve um bloco de bytes de uma conexao com porta RS232. */
int rs232_conn_write(rs232_conn_ptr conn, uint8_t* buffer, int length)
{
	if (conn == NULL) return 0;
	if (conn->_win32_handle == INVALID_HANDLE_VALUE) return 0;
	DWORD count = length;
	BOOL result = WriteFile(conn->_win32_handle, buffer, length, &count, NULL);
	if (result == 0) return 0;
	return count;
}


/* fecha a conexao com uma conexao com RS232. */
void rs232_conn_close(rs232_conn_ptr conn)
{
	if (conn == NULL) return;
	if (conn->_win32_handle == INVALID_HANDLE_VALUE) return;
	CloseHandle(conn->_win32_handle);
	conn->_win32_handle = INVALID_HANDLE_VALUE;
}

/* apaga a estrutura sobre uma conexao com RS232. */
void rs232_conn_dispose(rs232_conn_ptr* conn)
{
	if (conn == NULL) return;
	if (*conn == NULL) return;
	rs232_conn_close(*conn);
	free((void*)(*conn));
	*conn = NULL;
}

#endif /* _WIN32 */
