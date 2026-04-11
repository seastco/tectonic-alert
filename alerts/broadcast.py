import logging
from alerts.notification_service import NotificationService
from storage.subscribers import Subscribers

logger = logging.getLogger(__name__)


def lambda_handler(event, context):
    message = event.get("message")
    if not message:
        return {"statusCode": 400, "body": "No message specified"}

    subscribers = Subscribers().get_subscribers()
    NotificationService().send_alert(message, subscribers)
    logger.info(f"Broadcast sent to {len(subscribers)} subscribers")
    return {"statusCode": 200, "body": f"Sent to {len(subscribers)} subscribers"}
