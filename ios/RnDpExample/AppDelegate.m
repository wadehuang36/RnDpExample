#import "AppDelegate.h"
#import <UserNotifications/UserNotifications.h>

#import <React/RCTBridge.h>
#import <React/RCTBundleURLProvider.h>
#import <React/RCTRootView.h>
#import <React/RCTLinkingManager.h>

#ifdef FB_SONARKIT_ENABLED
#import <FlipperKit/FlipperClient.h>
#import <FlipperKitLayoutPlugin/FlipperKitLayoutPlugin.h>
#import <FlipperKitUserDefaultsPlugin/FKUserDefaultsPlugin.h>
#import <FlipperKitNetworkPlugin/FlipperKitNetworkPlugin.h>
#import <SKIOSNetworkPlugin/SKIOSNetworkAdapter.h>
#import <FlipperKitReactPlugin/FlipperKitReactPlugin.h>

static void InitializeFlipper(UIApplication *application) {
  FlipperClient *client = [FlipperClient sharedClient];
  SKDescriptorMapper *layoutDescriptorMapper = [[SKDescriptorMapper alloc] initWithDefaults];
  [client addPlugin:[[FlipperKitLayoutPlugin alloc] initWithRootNode:application withDescriptorMapper:layoutDescriptorMapper]];
  [client addPlugin:[[FKUserDefaultsPlugin alloc] initWithSuiteName:nil]];
  [client addPlugin:[FlipperKitReactPlugin new]];
  [client addPlugin:[[FlipperKitNetworkPlugin alloc] initWithNetworkAdapter:[SKIOSNetworkAdapter new]]];
  [client start];
}
#endif

@interface AppDelegate() <UNUserNotificationCenterDelegate>
@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
#ifdef FB_SONARKIT_ENABLED
  InitializeFlipper(application);
#endif

  // initialize notification
  if ([UNUserNotificationCenter class] != nil) {
    [UNUserNotificationCenter currentNotificationCenter].delegate = self;
    UNAuthorizationOptions authOptions = UNAuthorizationOptionAlert | UNAuthorizationOptionSound | UNAuthorizationOptionBadge;
    [[UNUserNotificationCenter currentNotificationCenter] requestAuthorizationWithOptions:authOptions completionHandler:^(BOOL granted, NSError * _Nullable error) {
        
      if (granted) {
        dispatch_async(dispatch_get_main_queue(), ^{
          [application registerForRemoteNotifications];
        });
      }
      
      if (error != nil) {
        NSLog( @"Notiication initialize failed, %@ - %@", error.localizedFailureReason, error.localizedDescription );
      }
    }];
  };

  // read notification data, if the message has a link
  // put the link to UIApplicationLaunchOptionsURLKey in launchOptions
  NSDictionary* notification = [launchOptions valueForKey:UIApplicationLaunchOptionsRemoteNotificationKey];
  if (notification != nil) {
    NSString* link = [notification valueForKeyPath:@"aps.link"];
    
    if (link != nil) {
      [launchOptions setValue:link forKey:UIApplicationLaunchOptionsURLKey];
    }
  }

  RCTBridge *bridge = [[RCTBridge alloc] initWithDelegate:self launchOptions:launchOptions];
  RCTRootView *rootView = [[RCTRootView alloc] initWithBridge:bridge
                                                   moduleName:@"RnDpExample"
                                            initialProperties:nil];

  rootView.backgroundColor = [[UIColor alloc] initWithRed:1.0f green:1.0f blue:1.0f alpha:1];

  self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
  UIViewController *rootViewController = [UIViewController new];
  rootViewController.view = rootView;
  self.window.rootViewController = rootViewController;
  [self.window makeKeyAndVisible];
  return YES;
}

- (NSURL *)sourceURLForBridge:(RCTBridge *)bridge
{
#if DEBUG
  return [[RCTBundleURLProvider sharedSettings] jsBundleURLForBundleRoot:@"index" fallbackResource:nil];
#else
  return [[NSBundle mainBundle] URLForResource:@"main" withExtension:@"jsbundle"];
#endif
}

// for deep link
- (BOOL)application:(UIApplication *)application
   openURL:(NSURL *)url
   options:(NSDictionary<UIApplicationOpenURLOptionsKey,id> *)options
{
  return [RCTLinkingManager application:application openURL:url options:options];
}

// print token for debug purpose
- (void)application:(UIApplication *) application didRegisterForRemoteNotificationsWithDeviceToken:(nonnull NSData *)deviceToken {
  const char *data = [deviceToken bytes];
  NSMutableString *token = [NSMutableString string];

  for (NSUInteger i = 0; i < [deviceToken length]; i++) {
      [token appendFormat:@"%02.2hhX", data[i]];
  }

  NSLog(@"APN Token: %@", [token copy]);
}

// recieve notification when app is in frontground
- (void)userNotificationCenter:(UNUserNotificationCenter *)center
         willPresentNotification:(UNNotification *)notification
         withCompletionHandler:(void (^)(UNNotificationPresentationOptions options))completionHandler {
  completionHandler(UNNotificationPresentationOptionAlert + UNNotificationPresentationOptionSound + UNNotificationPresentationOptionBadge);
}

// handle tapping notifications and trigger the event
- (void)userNotificationCenter:(UNUserNotificationCenter *)center
        didReceiveNotificationResponse:(UNNotificationResponse *)response
         withCompletionHandler:(void(^)(void))completionHandler  {  
  NSDictionary *userInfo = response.notification.request.content.userInfo;

  NSString *link = [userInfo valueForKeyPath:@"aps.link"];

  if (link != nil) {
    [RCTLinkingManager application:UIApplication.sharedApplication openURL:[NSURL URLWithString:link] options: [NSDictionary alloc]];
  }

  completionHandler();
}

@end
