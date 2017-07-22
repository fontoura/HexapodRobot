/*
 * BaseRef.hpp
 *
 *  Created on: 11/09/2013
 */

#include <cstdlib>
#include "../../base/all.h"

namespace concurrent
{
	namespace managed
	{
		BaseRef::~BaseRef()
		{
		}

		template <typename T> base::ControlBlock* BaseRef::ctrlBlkOf(T* obj)
		{
			return base::Object::ctrlBlkOf(obj);
		}
	}
}
