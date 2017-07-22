/*
 * LegsDriver.hpp
 *
 *  Created on: 09/09/2013
 */

#ifndef DRIVERS_LEGSDRIVER_HPP_
#define DRIVERS_LEGSDRIVER_HPP_

namespace drivers
{

	LegsDriver::LegsDriver()
	{
	}

	LegsDriver::~LegsDriver()
	{
	}

	void LegsDriver::initialize()
	{
		for (int leg = 0; leg < 6; leg ++)
		{
			m_legs[leg].changed = true;
		}
	}

	void LegsDriver::setPosition(int leg, int x, int y, int z)
	{
		if (m_legs[leg].x != x || m_legs[leg].y != y || m_legs[leg].z != z)
		{
			m_legs[leg].changed = true;
			m_legs[leg].x = x;
			m_legs[leg].y = y;
			m_legs[leg].z = z;
		}
	}

	int LegsDriver::getX(int leg)
	{
		return m_legs[leg].x;
	}

	int LegsDriver::getY(int leg)
	{
		return m_legs[leg].y;
	}

	int LegsDriver::getZ(int leg)
	{
		return m_legs[leg].z;
	}

}

#endif /* DRIVERS_LEGSDRIVER_HPP_ */
