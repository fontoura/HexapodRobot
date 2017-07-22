/*
 * concurrent.jobs.h
 *
 *  Created on: 01/02/2013
 *      Author: Felipe Michels Fontoura
 */

#ifndef CONCURRENT_JOBS_H_
#define CONCURRENT_JOBS_H_

#include "base.h"
#include "concurrent.managed.h"
#include "concurrent.thread.h"

namespace concurrent
{
	namespace jobs
	{
		/**
		 * Classe representando uma fila de tarefas.
		 */
		class JobQueue :
			public virtual base::Object
		{
			protected:
				/* construtor e destrutor. */
				JobQueue();
				virtual ~JobQueue();

			public:
				/**
				 * Obtém uma nova instância de fila de tarefas.
				 * @return Instância de fila de tarefas.
				 */
				static JobQueue* create();

			public:
				/**
				 * Enfilera uma tarefa para execução futura.
				 * @param body Objeto com a tarefa.
				 */
				virtual void enqueue(_strong(thread::ThreadBody)& body) = 0;
		};
	}
}

#endif /* CONCURRENT_JOBS_H_ */
