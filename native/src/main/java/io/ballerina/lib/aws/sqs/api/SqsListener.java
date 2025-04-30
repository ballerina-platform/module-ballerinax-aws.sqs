package io.ballerina.lib.aws.sqs.api;

import io.ballerina.lib.aws.sqs.impl.SqsPollCycleFutureListener;

/**
 * This interface defines listener which can be registered, to retrieve Kafka records returned from single poll cycle.
 */
public interface SqsListener {

    /**
     * For each poll cycle, it will trigger invocation to this method dispatching polled kafka records.
     *
     * @param listener      which control the flow of poll cycle
     * @param groupID       ID of the consumer group in which the consumer belongs
     */
    void onMessagesReceived(String groupID,
                           SqsPollCycleFutureListener listener);

    /**
     * If there are errors, Kafka connector will trigger this method.
     *
     * @param throwable contains the error details of the event.
     */
    void onError(Throwable throwable);
}
