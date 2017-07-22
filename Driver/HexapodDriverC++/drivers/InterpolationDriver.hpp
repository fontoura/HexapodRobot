/*
 * InterpolationDriver.hpp
 *
 *  Created on: 09/09/2013
 */

#ifndef DRIVERS_INTERPOLATIONDRIVER_HPP_
#define DRIVERS_INTERPOLATIONDRIVER_HPP_

#include "InterpolationDriver.h"

namespace drivers
{

	InterpolationDriver::InterpolationDriver()
	{
	}

	InterpolationDriver::~InterpolationDriver()
	{
	}

	void InterpolationDriver::setPosition(int leg, int x, int y, int z)
	{
		m_xyz[leg].x = x;
		m_xyz[leg].y = y;
		m_xyz[leg].z = z;
	}

}

#endif /* DRIVERS_INTERPOLATIONDRIVER_HPP_ */
