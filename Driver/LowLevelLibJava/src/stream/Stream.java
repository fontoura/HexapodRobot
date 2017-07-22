package stream;

public interface Stream {
	public boolean open();

	public boolean close();

	public boolean isOpen();

	public boolean setTimeouts(Timeouts timeouts);

	public void getTimeouts(Timeouts timeouts);

	public int read(byte[] buffer, int offset, int length);

	public int write(byte[] buffer, int offset, int length);

	public final class Timeouts {
		public long relative;
		public long absolute;

		public Timeouts() {
		}

		public Timeouts(long absolute, long relative) {
			this.absolute = absolute;
			this.relative = relative;
		}
	}
}
