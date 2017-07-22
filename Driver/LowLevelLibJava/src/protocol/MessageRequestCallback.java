package protocol;

public interface MessageRequestCallback {
	public void onRequest(Message request, FlowReplier replier);
}
