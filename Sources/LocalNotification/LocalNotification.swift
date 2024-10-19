#if os(iOS) // LocalNotification is only available for iOS devices
import Foundation // Import Foundation framework for basic data types and operations
import UserNotifications // Import UserNotifications framework for local and remote notifications
import CoreFoundation // Import CoreFoundation framework for low-level data types and operations
/**
 * - Abstract: There are totally 3 kind of notification styles in iOS.
 *             They are: (User can toggle the available of different kinds of
 *             notification at the system Settings)
 * 1. Lock Screen — Body message is hidden before device is unlocked by user
 * 2. Notification Centre — After unlocking the device, user can manage the notification at Notification Centre
 * 3. Banners-Unlock — New notification is pop up at the top of the screen.
 * - Description: Local notifications are scheduled and “sent” locally on
 *                your iPhone, so they aren’t sent over the internet. Typical
 *                use cases are calendar reminders or the iPhone alarm clock.
 * - Important: ⚠️️ Once your notification has been added press Cmd+L in the simulator to lock the screen. After a few seconds have passed the device should wake up with a sound, and show our message – nice!
 * - Important: ⚠️️ Something you need to know about the notifications. They will not show up if you app is in the foreground. In order to see this notification, you will need to run the app and then background the app immediately.
 * - Important: ⚠️️ Turn off do not disturb mode / focus mode / silent mode in iOS settings etc to test notifications (or keep it on to hide notifications)
 * - Remark: LocalNotification API is great for debugging when iOS is in
 *           suspended mode and logging doesn't work
 * - Remark: UserNotifications: lets us create notifications to the user
 *           that can be shown on the lock screen.
 * - Remark: We have two types of notifications to work with, and they
 *           differ depending on where they were created: local
 *           notifications are ones we schedule locally, and remote
 *           notifications (commonly called push notifications) are sent
 *           from a server somewhere.
 * - Remark: We have to request authorization to show alerts.
 * - Remark: The most common thing to do is ask for permission to show alerts,
 *           badges, and sounds – that doesn’t mean we need to use all of them at
 *           the same time, but asking permission up front means we can be
 *           selective later on.
 * - Remark: When we tell iOS what kinds of notifications we want, it will show
 *           a prompt to the user so they have the final say on what our app can
 *           do. When they make their choice, a closure we provide will get
 *           called and tell us whether the request was successful or not.
 * - Fixme: ⚠️️ Clean up comments in this class etc, move some doc to a readme?
 * - Fixme: ⚠️️ Add support for foreground delegate: https://cocoacasts.com/local-notifications-with-the-user-notifications-framework
 * - Fixme: ⚠️️ Handle notification actions. https://cocoacasts.com/actionable-notifications-with-the-user-notifications-framework
 * - Fixme: ⚠️️ To add actions, foreground, attachments see: https://itnext.io/swift-local-notification-all-in-one-ee6027ea6e3
 * - Fixme: ⚠️️ More advance functionality: https://gist.github.com/hemangshah/0b19d796ea5e46abcb4702db96195321
 * - Fixme: ⚠️️ A lib on github: https://github.com/d7laungani/DLLocalNotifications
 * - Fixme: ⚠️️ make internal only? because only used for debugging restoration-mode etc?
 */
public final class LocalNotification { // Used to debug restoration mode
   /**
    * Request permission for notifications.
    * - Description: Request authentication to show lcoal notification in the app
    *               (Should be done once at app startup) (only allowed to be done
    *               once per app-life-time)
    * - Remark: UNUserNotificationCenter handles all notification-related behavior
    *           in the app. This includes requesting authorization, scheduling
    *           delivery and handling actions
    * ## Examples
    * if !LocalNotification.isNotificationAvailable {
    *    LocalNotification.requestPermission()
    * }
    */
   @discardableResult public static func requestPermission() -> Bool {
      var result = false // Autherized or not
      let semaphore: DispatchSemaphore = .init(value: 0)// We use semaphore to make this sync
      let userNotificationCenter: UNUserNotificationCenter = .current() // Notification center property
      let authOptions: UNAuthorizationOptions = [
         .alert, // The option to display an alert
         .badge, // The option to update the app's badge
         .sound // The option to play a sound
      ] // When we ask the user to grant the app permission to display the notifications, we have to specify what the notifications will want to use. In our case we will ask the user to authenticate for
      // When we make the request, it will tell the user what type of notifications we might send to them.
      userNotificationCenter.requestAuthorization(options: authOptions) { (_ success: Bool, _ error) in
         if success {
            result = true  // If the request was successful, set the result to true
         } else if let error = error {
            Swift.print("Err ⚠️️, Request Authorization Failed (\(error), \(error.localizedDescription))")
            result = false // If there was an error, print the error message and set the result to false
         }
         semaphore.signal() // Continue
      }
      // We wait until user has interacted with the notification
      semaphore.wait() // (wallTimeout: .distantFuture)
      return result
   }
   /**
    * Create, schedule and manage different types of local notifications
    * - Description: Let's us request a notification to be shown in a certain
    *                number of seconds from now
    * - Remark: The content is what should be shown, and can be a title,
    *           subtitle, sound, image, and so on.
    * - Remark: The trigger determines when the notification should be shown,
    *           and can be a number of seconds from now, a date and time in the
    *           future, or a location.
    * - Remark: The request combines the content and trigger, but also adds a
    *           unique identifier so you can edit or remove specific alerts later
    *           on. If you don’t want to edit or remove stuff, use UUID().uuidString
    *           to get a random identifier.
    * - Remark: You can also make date based triggers:
    *           `UNCalendarNotificationTrigger(dateMatching:
    *           calendar.current.dateComponents([.day, .month, .year, .hour,
    *           .minute], from: date)`
    * - Remark: Date example 20 secs from now:
    *           `let fireDate = Calendar.current.dateComponents([.day, .month,
    *           .year, .hour, .minute, .second], from: Date().addingTimeInterval(20))`
    * - Remark: There are also location based triggers
    * - Remark: It's also possible to add content to a notification via
    *           UNNotificationAttachment: see
    *           https://programmingwithswift.com/how-to-send-local-notification-with-swift-5/
    * - Remark: There is also badge in the content: update the application's badge
    *           number
    * - Remark: There is also content.userinfo like: content.userInfo = ["value":
    *           "Data with local notification"]  the information you want to
    *           associate with local notification. This is useful in cases, where
    *           we want to check the data associated with notification.
    * ## Examples:
    * guard LocalNotification.isNotificationAvailable else { print("Err, notification not allowed"); return }
    * LocalNotification.showNotification(title: "Feed the cat", body: "It looks hungry")
    * - Parameters:
    *   - title: Title of notification
    *   - subTitle: A secondary description for the notification. (As of iOS 10,
    *               you can define a title as well as a subtitle.)
    *   - timeInterval: Show this notification n seconds from now
    *   - id: Choose a random identifier (must be unique or it will only show the
    *         first, use "someID" + UUID().uuidString) 
    *   - sound: The sound to play during notification delivery
    *   - body: Message associated with the notification. (Body text is hidden
    *           before unlock)
    */
   public static func showNotification(title: String, subTitle: String? = nil, body: String? = nil, timeInterval: Double = 1.0, id: String = UUID().uuidString, sound: UNNotificationSound? = UNNotificationSound.default) {
      if !isNotificationAvailable { requestPermission() } // Request to show notification (done only once per app lifetime) ⚠️️ This is needed for testing - Fixme: ⚠️️ Use guard? maybe not
      let content = UNMutableNotificationContent() // Create new notifcation content instance
      content.title = title // Set the title of the notification content
      if let subTitle: String = subTitle { content.subtitle = subTitle } // Set the subtitle of the notification content if it exists
      if let body: String = body { content.body = body } // Set the body of the notification content if it exists
      if let sound: UNNotificationSound = sound { content.sound = sound } // Set the sound of the notification content if it exists
      let trigger: UNTimeIntervalNotificationTrigger = .init(
         timeInterval: timeInterval, // The time interval after which to trigger the notification
         repeats: false // A boolean value indicating whether the notification should repeat
      ) // Schedule Local Notification
      let request: UNNotificationRequest = .init(
         identifier: id, // The identifier for the notification request
         content: content, // The content of the notification request
         trigger: trigger // The trigger for the notification request
      )
      // Add our Request to User Notification Center (Schedule the request with the system)
      UNUserNotificationCenter.current().add(request)
   }
}
/**
 * Getter
 */
extension LocalNotification {
   /**
    * Assert if we can send notification or not
    * - Remark: If the application was already granted permission to display
    *           notifications, we can go ahead and schedule a local notification.
    * - Remark: If no other switch cases match, i.e. in the case of .denied, we
    *           simply do nothing. We can’t ask for permission again, and we also
    *           can’t schedule local notifications
    * - Remark: On iOS, you can only ask for permission once. When permission has
    *           explicitly been denied, it has to be manually reset by the user via
    *           the iPhone’s Settings app. That’s why you always want to make it
    *           clear why an app is asking for permission. Many apps also use a 2-step
    *           approach, i.e. first ask for a soft permission (or prepare the user
    *           the permissions dialog is coming up), and then use the iOS-provided
    *           permission dialog.
    * - Fixme: ⚠️️ We could make a method that returns the state of access, so we can
    *           notify user to change notification settings etc
    */
   public static var isNotificationAvailable: Bool {
      guard let notificationSettings: UNNotificationSettings = Self.notificationSettings else { // If unable to get notification settings, print an error message and return false
         Swift.print("Err, ⚠️️ unable to get notificationSettings")
         return false
      }
      switch notificationSettings.authorizationStatus {
      case .notDetermined: // If the authorization status is not determined, request authorization
         Swift.print("notDetermined -> Request Authorization")
         return false
      case .authorized: // If the authorization status is authorized, schedule the local notification
         Swift.print("authorized -> Schedule Local Notification")
         return true
      case .denied: // If the authorization status is denied, the application is not allowed to display notifications
         Swift.print("denied -> Application Not Allowed to Display Notifications")
         return false
      default: // For any other authorization status, return false
         Swift.print("default -> other reason")
         return false
      }
   }
   /**
    * - Remark: Why do we ask for the notification settings of the application?
    *           We do this to determine if the application previously requested
    *           the user's permission.
    */
   fileprivate static var notificationSettings: UNNotificationSettings? {
      var result: UNNotificationSettings? // Initialize a variable to hold the notification settings
      let semaphore: DispatchSemaphore = .init(value: 0) // We use semaphore to make this sync
      UNUserNotificationCenter.current().getNotificationSettings { (_ settings: UNNotificationSettings) in // Request Notification Settings
         result = settings // Set the result to the notification settings
         semaphore.signal() // Signal the semaphore to indicate that the operation is complete
      }
      _ = semaphore.wait(timeout: DispatchTime.now() + 3) // (wallTimeout: .distantFuture)
      return result // Return the notification settings
   }
}
/**
 * Ext
 */
extension LocalNotification {
   /**
    * - Remark: Use this to toggle `LocalNotification` usage on or off
    */
   public static var isDebug: Bool { false }
}
#endif
// public static let shared: LocalNotification = .init() // remove this?
