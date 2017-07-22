/*
 * global.hpp
 *
 *  Created on: 22/03/2013
 */

namespace global
{

	uint16_t checksum16(uint8_t* bytes, int offset, int length)
	{
		bytes += offset;
		if (length <= 0)
		{
			return 0;
		}
		uint16_t checksum = 0;
		while (length)
		{
			checksum += (0xFF & *bytes);
			length--;
			bytes++;
		}
		return checksum;
	}

	void writeLittleEndian16(uint8_t* target, int offset, uint16_t value)
	{
		target[offset + 0] = value & 0xFF;
		target[offset + 1] = (value >> 8) & 0xFF;
	}

	void writeLittleEndian32(uint8_t* target, int offset, uint32_t value)
	{
		target[offset + 0] = value & 0xFF;
		target[offset + 1] = (value >> 8) & 0xFF;
		target[offset + 2] = (value >> 16) & 0xFF;
		target[offset + 3] = (value >> 24) & 0xFF;
	}

	uint16_t readLittleEndian16(uint8_t* source, int offset)
	{
		return (source[offset + 0] & 0xFF) | ((source[offset + 1] & 0xFF) << 8);
	}

	uint32_t readLittleEndian32(uint8_t* source, int offset)
	{
		return (source[offset + 0] & 0xFF) | ((source[offset + 1] & 0xFF) << 8) | ((source[offset + 2] & 0xFF) << 16) | ((source[offset + 3] & 0xFF) << 24);
	}
}
