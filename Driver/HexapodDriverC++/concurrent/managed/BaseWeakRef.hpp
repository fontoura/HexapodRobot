/*
 * BaseWeakRef.hpp
 *
 *  Created on: 11/09/2013
 */

#include <cstdlib>

#include "../../base/all.h"

namespace concurrent
{
	namespace managed
	{
		BaseWeakRef::~BaseWeakRef()
		{
		}

		base::ControlBlock* BaseWeakRef::getCtrlBlk()
		{
			return m_ctrlBlk;
		}
	}
}
