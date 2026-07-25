import Foundation
import UserNotifications

/// Manages local notifications for streak reminders and daily practice prompts.
@MainActor
final class NotificationManager {
    static let shared = NotificationManager()

    private init() {}

    // MARK: - Permission

    /// Request notification permission.
    func requestPermission() async -> Bool {
        do {
            let granted = try await UNUserNotificationCenter.current()
                .requestAuthorization(options: [.alert, .badge, .sound])
            return granted
        } catch {
            print("[NotificationManager] Permission error: \(error)")
            return false
        }
    }

    // MARK: - Daily Reminder

    /// Schedule a daily practice reminder at a specific hour.
    func scheduleDailyReminder(hour: Int = 19, minute: Int = 0) {
        let center = UNUserNotificationCenter.current()

        // Remove existing daily reminders first.
        center.removePendingNotificationRequests(withIdentifiers: ["daily_practice_reminder"])

        let content = UNMutableNotificationContent()
        content.title = "Time to Practice! 🔥"
        content.body = "Don't break your streak! Keep learning today."
        content.sound = .default
        content.badge = 1

        // Custom data for tracking.
        content.userInfo = ["type": "daily_reminder"]

        var dateComponents = DateComponents()
        dateComponents.hour = hour
        dateComponents.minute = minute

        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)

        let request = UNNotificationRequest(
            identifier: "daily_practice_reminder",
            content: content,
            trigger: trigger
        )

        center.add(request) { error in
            if let error = error {
                print("[NotificationManager] Failed to schedule: \(error)")
            }
        }
    }

    // MARK: - Streak Milestone

    /// Send a streak milestone notification.
    func sendStreakMilestone(days: Int) {
        let center = UNUserNotificationCenter.current()

        let content = UNMutableNotificationContent()
        content.title = "Streak Milestone! 🎉"
        content.body = "You've hit \(days) days in a row! Keep it up!"
        content.sound = .default

        let request = UNNotificationRequest(
            identifier: "streak_milestone_\(days)",
            content: content,
            trigger: nil // Immediate
        )

        center.add(request)
    }

    // MARK: - Streak at Risk

    /// Send a "streak at risk" notification if user hasn't practiced today.
    func sendStreakAtRiskReminder() {
        let center = UNUserNotificationCenter.current()

        // Remove existing streak-at-risk reminders.
        center.removePendingNotificationRequests(withIdentifiers: ["streak_at_risk"])

        let content = UNMutableNotificationContent()
        content.title = "Your Streak is at Risk! ⚠️"
        content.body = "You haven't practiced today. Open Langly to keep your streak alive!"
        content.sound = .default
        content.badge = 1

        // Schedule for 9 PM if not yet practiced.
        var dateComponents = DateComponents()
        dateComponents.hour = 21
        dateComponents.minute = 0

        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)

        let request = UNNotificationRequest(
            identifier: "streak_at_risk",
            content: content,
            trigger: trigger
        )

        center.add(request)
    }

    // MARK: - Cancel

    /// Cancel all scheduled notifications.
    func cancelAll() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
    }

    /// Cancel specific notification.
    func cancel(identifier: String) {
        UNUserNotificationCenter.current()
            .removePendingNotificationRequests(withIdentifiers: [identifier])
    }
}
