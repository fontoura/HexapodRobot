/*
 * concurrent.thread.h
 *
 *  Created on: 28/11/2012
 */

#ifndef CONCURRENT_THREAD_H_
#define CONCURRENT_THREAD_H_

#include "base/all.h"
#include "concurrent/managed/all.h"

namespace concurrent
{
	namespace thread
	{
		/*
		 * Classe representando um corpo de thread.
		 */
		class ThreadBody :
			public virtual base::Object
		{
			public:
				/** construtor e destrutor. */
				inline ThreadBody();
				inline virtual ~ThreadBody();

			public:
				/* método que executa o corpo da thread. */
				virtual void run() = 0;
		};

		enum ThreadPriority {
			LowThreadPriority = 0,
			RegularThreadPriority = 1,
			HighThreadPriority = 2
		};

		/*
		 * Classe representando uma thread.
		 */
		class Thread :
			public virtual base::Object
		{
			protected:
				/** construtor e destrutor. */
				inline Thread();
				inline virtual ~Thread();

			public:
				/* método que define a prioridade de uma thread. */
				virtual void setPriority(ThreadPriority value) = 0;

				/* método que inicia a thread. */
				virtual void start() = 0;

				/* método que executa o corpo da thread. */
				virtual void run() = 0;

				/* espera indefinidamente pelo término da thread. */
				virtual bool join() = 0;

				/* espera um certo tempo pelo término da thread. */
				virtual bool join(int milliseconds) = 0;

				/* bota a thread atual para dormir por algum tempo. */
				static void sleep(long milliseconds);

				/* método que cria uma thread. */
				static Thread* create(ThreadBody* body);
		};
	}
}

#include "concurrent.thread.hpp"

#endif /* CONCURRENT_THREAD_H_ */
