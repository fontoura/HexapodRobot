package concurrent.semaphore;

import java.util.concurrent.TimeUnit;

public class Semaphore {
	private int m_maximum;
	private java.util.concurrent.Semaphore m_semaphore;

	protected Semaphore(int current, int maximum) {
		m_semaphore = new java.util.concurrent.Semaphore(current);
	}

	public int getMaximum() {
		return m_maximum;
	}

	public int getCount() {
		return m_semaphore.availablePermits();
	}

	public void up() {
		m_semaphore.release();
	}

	public boolean down() {
		try {
			m_semaphore.acquire();
			return true;
		} catch (InterruptedException e) {
			return false;
		}
	}

	public boolean down(int miliseconds) {
		try {
			return m_semaphore.tryAcquire(miliseconds, TimeUnit.MILLISECONDS);
		} catch (InterruptedException e) {
			return false;
		}
	}

	public static Semaphore create(int current, int maximum) {
		return new Semaphore(current, maximum);
	}
}
