package concurrent.time;

public class Stoptimer {
	private long m_base;

	public Stoptimer() {
		this.reset();
	}
	
	public void reset() {
		m_base = System.currentTimeMillis();
	}
	
	public long getMilliseconds() {
		return System.currentTimeMillis() - m_base;
	}
}
