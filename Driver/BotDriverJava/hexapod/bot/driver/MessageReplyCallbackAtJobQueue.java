package bot.driver;

import concurrent.jobs.JobQueue;
import protocol.Message;
import protocol.MessageReplyCallback;

public abstract class MessageReplyCallbackAtJobQueue implements MessageReplyCallback {
	private JobQueue m_queue;

	public MessageReplyCallbackAtJobQueue(JobQueue queue) {
		m_queue = queue;
	}

	@Override
	public void onReply(final Message request, final Message reply, final int error) {
		m_queue.enqueue(new Runnable() {
			@Override
			public void run() {
				MessageReplyCallbackAtJobQueue.this.onReplyJob(request, reply, error);
			}
		});
	}

	public abstract void onReplyJob(Message request, Message reply, int error);
}
