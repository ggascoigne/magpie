import AppKit
import SwiftUI
import MagpieCore

@main
struct MagpieApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate
    @StateObject private var model = AppModel()

    var body: some Scene {
        MenuBarExtra {
            MenuBarContent(model: model, launchAtLogin: model.launchAtLogin)
        } label: {
            MenuBarLabel(model: model)
        }
        .menuBarExtraStyle(.menu)

        Window("Magpie — Task Browser", id: "task-browser") {
            TaskBrowserRootView(
                settings: model.settings,
                requestedTaskID: $model.taskBrowserSelection,
                onAddTask: { model.showQuickCapture(includeSelectedText: false) }
            )
                .frame(minWidth: 960, minHeight: 600)
        }
        .commands {
            CommandGroup(replacing: .newItem) {
                Button("Quick Capture") {
                    model.showQuickCapture()
                }
                .keyboardShortcut(
                    model.settings.quickCaptureShortcut.menuKeyEquivalent,
                    modifiers: model.settings.quickCaptureShortcut.menuModifiers
                )
            }
            TaskBrowserMenuCommands()
        }
        .defaultSize(width: 1_220, height: 760)
        .defaultPosition(.center)
        .defaultLaunchBehavior(.suppressed)
        .windowResizability(.contentMinSize)
    }
}

private struct MenuBarLabel: View {
    @ObservedObject var model: AppModel
    @Environment(\.openWindow) private var openWindow

    var body: some View {
        Label("Magpie", systemImage: "checkmark.circle")
            .onAppear {
                model.configureTaskBrowserPresenter {
                    openWindow(id: "task-browser")
                }
            }
    }
}

private struct MenuBarContent: View {
    @ObservedObject var model: AppModel
    @ObservedObject var launchAtLogin: LaunchAtLoginController

    var body: some View {
        if !model.menuTasks.isEmpty {
            Section("Now & Upcoming") {
                ForEach(model.menuTasks) { task in
                    Button {
                        model.showTaskBrowser(selecting: task.uuid)
                    } label: {
                        Label(menuTaskTitle(task), systemImage: task.isActive ? "play.circle.fill" : "calendar")
                    }
                }
            }

            Divider()
        }

        Button("Task Browser") {
            model.showTaskBrowser()
        }
        .keyboardShortcut(
            model.settings.taskBrowserShortcut.menuKeyEquivalent,
            modifiers: model.settings.taskBrowserShortcut.menuModifiers
        )
        .onAppear { model.refreshMenuTasks() }

        Button("Quick Capture") {
            model.showQuickCapture()
        }
        .keyboardShortcut(
            model.settings.quickCaptureShortcut.menuKeyEquivalent,
            modifiers: model.settings.quickCaptureShortcut.menuModifiers
        )

        Divider()

        Button("About Magpie") {
            NSApp.orderFrontStandardAboutPanel(nil)
            NSApp.activate(ignoringOtherApps: true)
        }

        Button("Settings…") {
            model.showSettings()
        }

        Divider()

        Button("Quit Magpie") {
            NSApp.terminate(nil)
        }
        .keyboardShortcut("q")
    }

    private func menuTaskTitle(_ task: TaskRecord) -> String {
        if task.isActive { return "Active: \(task.description)" }
        return "Due \(browserDueDisplayValue(task.due)): \(task.description)"
    }
}
