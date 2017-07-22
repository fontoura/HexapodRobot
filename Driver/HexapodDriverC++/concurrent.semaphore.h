/*
 * concurrent.semaphore.h
 *
 *  Created on: 28/11/2012
 */

#ifndef CONCURRENT_SEMAPHORE_H_
#define CONCURRENT_SEMAPHORE_H_

#include "base/all.h"

namespace concurrent
{
	namespace semaphore
	{
		class Semaphore :
			public virtual base::Object
		{
			protected:
				/** construtor e destrutor. */
				Semaphore();
				virtual ~Semaphore();

			public:
				/** obtém uma nova instância de semáforo. */
				static Semaphore* create(int count, int maximum);

			public:
				/** obtém a contagem máxima do semáforo. */
				virtual int getMaximum() = 0;

				/** obtém a contagem atual do semáforo. */
				virtual int getCount() = 0;

				/** libera um permit do semáforo. */
				virtual void up() = 0;

				/** espera indefinidamente até obter um permit do semáforo. */
				virtual bool down() = 0;

				/** espera um certo tempo até obter um permit do semáforo. */
				virtual bool down(int milliseconds) = 0;
		};
	}
}

#endif /* CONCURRENT_SEMAPHORE_H_ */
