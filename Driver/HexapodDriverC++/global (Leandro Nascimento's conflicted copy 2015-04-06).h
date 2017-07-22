/*
 * global.h
 *
 *  Created on: 22/03/2013
 *      Author: Felipe Michels Fontoura
 */

#ifndef GLOBAL_H_
#define GLOBAL_H_

namespace global
{
	inline uint16_t checksum16(uint8_t* bytes, int offset, int length);
	inline void writeLittleEndian16(uint8_t* target, int offset, uint16_t value);
	inline void writeLittleEndian32(uint8_t* target, int offset, uint32_t value);
	inline uint16_t readLittleEndian16(uint8_t* source, int offset);
	inline uint32_t readLittleEndian32(uint8_t* source, int offset);
}

#include "global.hpp"

#endif /* GLOBAL_H_ */
