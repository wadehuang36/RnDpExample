package com.rndpexample;

import android.app.Notification;
import android.app.NotificationChannel;
import android.app.NotificationManager;
import android.app.PendingIntent;
import android.content.Context;
import android.content.Intent;
import android.net.Uri;
import android.os.Build;
import android.util.Log;

import androidx.annotation.NonNull;
import androidx.core.app.NotificationCompat;
import androidx.core.content.ContextCompat;

import com.google.firebase.messaging.FirebaseMessagingService;
import com.google.firebase.messaging.RemoteMessage;

import java.util.Map;

public class MessagingService extends FirebaseMessagingService {
  static String LogTag = MessagingService.class.getName();
  static String DefaultChannelID = "default";

  @Override
  public void onNewToken(@NonNull String token) {
    // print token for debug purpose
    Log.d(LogTag, "FCM Token:" + token);
  }

  @Override
  public void onMessageReceived(@NonNull RemoteMessage remoteMessage) {
    // handle message
    Map<String, String> data = remoteMessage.getData();
    if (!data.isEmpty()) {
      Context context = getApplicationContext();
      NotificationManager notificationManager = ContextCompat.getSystemService(context, NotificationManager.class);

      if (notificationManager == null) return;

      if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
        // create channel if it is not existed
        if (notificationManager.getNotificationChannel(DefaultChannelID) == null) {
          notificationManager.createNotificationChannel(new NotificationChannel(DefaultChannelID, "Default", NotificationManager.IMPORTANCE_DEFAULT));
        }
      }

      // the important part, if link is not null, create View with the link intent
      // so when the user taps the notification, behavior like deep link.
      String link = data.get("link");
      Intent intent = link == null ? new Intent(context, MainActivity.class) : new Intent(Intent.ACTION_VIEW, Uri.parse(link));

      Notification notification = new NotificationCompat.Builder(context, DefaultChannelID)
          .setSmallIcon(R.mipmap.ic_launcher)
          .setContentTitle(data.get("title"))
          .setContentText(data.get("body"))
          .setAutoCancel(true)
          .setContentIntent(PendingIntent.getActivity(context,0, intent, PendingIntent.FLAG_UPDATE_CURRENT))
          .build();

      notificationManager.notify(0, notification);
    }
  }
}
