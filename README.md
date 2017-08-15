# SSPusher
A simple push notification tool for iOS (HTTP/2)

This tool uses APNS's HTTP/2 setup to send push notifications thereby making it easier and effecient to send push notifications.

This tool supports ability to add custom headers like "apns-collapse-id", "apns-expiration", etc.

For all headers supported by APNS, please refer the link below:

https://developer.apple.com/library/content/documentation/NetworkingInternet/Conceptual/RemoteNotificationsPG/CommunicatingwithAPNs.html

You would need a valid p12 file with its password.

Rest is straightforward. Play around with the app to send push notes.

##############################################################################################################################

For all you terminal lovers out there, you can use the following curl command to achieve the same. 
Please note that your curl needs to support http2 for this to work

curl -d '{"aps" = {alert = {body = "Body of push notification";subtitle = "Subtitle of push notification";title = "Title of push notification";};"mutable-content" = 1;sound = default;category = "SecretCategory";};}' --cert "/Users/SS/Desktop/Certificate.pem":"secret" -H "apns-collapse-id:1712" --http2 https://api.development.push.apple.com/3/device/1234567890123456789012345678901234567890123456789012345678901234

For prod use: https://api.push.apple.com/3/device/

Feel free to reach out to me for any queries, suggesstions, bugs, improvements.

- Subbhaash S


Thanks to Rishabh Gupta for inspiring me to make this tool.
