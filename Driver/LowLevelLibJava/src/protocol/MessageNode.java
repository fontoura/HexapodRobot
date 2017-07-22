package protocol;

public class MessageNode {
	public MessageNode next;
	public Message message;
	public MessageReplyCallback callback;
	public long absoluteTimeout;
}
