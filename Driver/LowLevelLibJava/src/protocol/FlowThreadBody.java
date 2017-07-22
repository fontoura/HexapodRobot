package protocol;

class FlowThreadBody implements Runnable {
	private Flow m_flow;

	public FlowThreadBody(Flow flow) {
		m_flow = flow;
	}

	public void run() {
		m_flow.receive();
		m_flow = null;
	}
}