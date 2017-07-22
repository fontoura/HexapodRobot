/*
 * MovementOperation.cpp
 *
 *  Created on: 28/03/2013
 */

#include "../../bot/firmware/fw_defines.h"
#include "../../bot/firmware/MovementOperation.h"

namespace bot
{
	namespace firmware
	{
		MovementOperation::~MovementOperation()
		{
		}

		int MovementOperation::getLabel()
		{
			return m_label;
		}

		void MovementOperation::setLabel(int value)
		{
			m_label = value;
		}
	}
}
