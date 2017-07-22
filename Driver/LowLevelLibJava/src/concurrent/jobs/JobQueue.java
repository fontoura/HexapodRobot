package concurrent.jobs;

import concurrent.semaphore.Semaphore;

/**
 * Classe representando uma fila de tarefas.
 */
public class JobQueue {

	private Semaphore m_semaphore;
	private Thread m_thread;
	private JobNode m_first;
	private JobNode m_last;

	/* construtor. */
	private JobQueue() {
		m_semaphore = Semaphore.create(1, 1);
	}

	/**
	 * Enfilera uma tarefa para execução futura.
	 * @param body Objeto com a tarefa.
	 */
	public void enqueue(Runnable body) {
		JobNode node = new JobNode(body);
		m_semaphore.down();
		if (m_first == null) {
			m_first = node;
			m_last = node;
		} else {
			m_last.m_next = node;
			m_last = node;
		}
		if (m_thread == null) {
			m_thread = new Thread(new JobThread(this));
			m_thread.start();
		}
		m_semaphore.up();
	}

	/**
	 * Obtém uma nova instância de fila de tarefas.
	 * @return Instância de fila de tarefas.
	 */
	public static JobQueue create() {
		return new JobQueue();
	}

	private class JobNode {
		public Runnable m_body;
		public JobNode m_next;

		public JobNode(Runnable body) {
			m_body = body;
		}
	};

	private class JobThread implements Runnable {
		private JobQueue m_queue;

		public JobThread(JobQueue queue) {
			m_queue = queue;
		}

		public void run() {
			JobNode node = null;
			while (true) {
				m_queue.m_semaphore.down();
				node = m_queue.m_first;
				if (node != null) {
					m_queue.m_first = node.m_next;
					node.m_next = null;
					if (m_queue.m_first == null) {
						m_queue.m_last = null;
					}
				}
				if (node == null) {
					m_queue.m_thread = null;
				}
				m_queue.m_semaphore.up();

				if (node != null) {
					node.m_body.run();
					node.m_body = null;
					node = null;
				} else {
					break;
				}
			}
		}
	};
}
