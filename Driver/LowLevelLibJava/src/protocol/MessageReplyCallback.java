package protocol;

public interface MessageReplyCallback {
	public void onReply(Message request, Message reply, int error);
	
}
