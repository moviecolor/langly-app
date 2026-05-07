//
//  SettingsView.swift
//  LanglyApp
//
//  Created for Langly Task Management App
//

import SwiftUI

@available(iOS 17.0, *)
struct SettingsView: View {
    @ObservedObject var viewModel: SettingsViewModel
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationStack {
            Form {
                // App Icon Section
                Section(header: Text("App Icon")) {
                    AppIconPicker(selectedIcon: $viewModel.appIcon)
                        .onChange(of: viewModel.appIcon) { _ in
                            viewModel.saveSettings()
                        }
                }
                
                // Theme Section
                Section(header: Text("Appearance")) {
                    HStack {
                        Text("Theme")
                        Spacer()
                        Picker("Theme", selection: $viewModel.selectedTheme) {
                            Text("Light").tag("light")
                            Text("Dark").tag("dark")
                            Text("System").tag("system")
                        }
                        .pickerStyle(MenuPickerStyle())
                        .onChange(of: viewModel.selectedTheme) { _ in
                            viewModel.saveSettings()
                        }
                    }
                    
                    Toggle("Dark Mode", isOn: $viewModel.darkMode)
                        .onChange(of: viewModel.darkMode) { _ in
                            viewModel.saveSettings()
                        }
                }
                
                // Language Section
                Section(header: Text("Language")) {
                    HStack {
                        Text("Language")
                        Spacer()
                        Picker("Language", selection: $viewModel.selectedLanguage) {
                            Text("English").tag("en")
                            Text("Spanish").tag("es")
                            Text("French").tag("fr")
                            Text("German").tag("de")
                        }
                        .pickerStyle(MenuPickerStyle())
                        .onChange(of: viewModel.selectedLanguage) { _ in
                            viewModel.saveSettings()
                        }
                    }
                }
                
                // Notifications Section
                Section(header: Text("Notifications")) {
                    Toggle("Enable Notifications", isOn: $viewModel.notificationsEnabled)
                        .onChange(of: viewModel.notificationsEnabled) { _ in
                            viewModel.saveSettings()
                        }
                }
                
                // Reset Section
                Section {
                    Button("Reset to Default Settings") {
                        viewModel.resetToDefaultSettings()
                    }
                    .foregroundColor(.red)
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.large)
        }
    }
}

// MARK: - App Icon Picker
@available(iOS 17.0, *)
struct AppIconPicker: View {
    @Binding var selectedIcon: String
    
    let icons = [
        "app_icon_default",
        "app_icon_1",
        "app_icon_2",
        "app_icon_3",
        "app_icon_4"
    ]
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 16) {
                ForEach(icons, id: \.self) { icon in
                    AppIconButton(icon: icon, isSelected: selectedIcon == icon) {
                        selectedIcon = icon
                    }
                }
            }
            .padding(.horizontal)
        }
    }
}

// MARK: - App Icon Button
@available(iOS 17.0, *)
struct AppIconButton: View {
    let icon: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack {
                Image(systemName: icon)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 40, height: 40)
                    .foregroundColor(isSelected ? .blue : .secondary)
                    .padding(8)
                    .background(RoundedRectangle(cornerRadius: 8)
                        .fill(isSelected ? Color.blue.opacity(0.2) : Color.clear))
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(isSelected ? Color.blue : Color.clear, lineWidth: 2)
                    )
                
                Text(icon.replacingOccurrences(of: "app_icon_", with: ""))
                    .font(.caption)
                    .foregroundColor(isSelected ? .blue : .secondary)
            }
            .frame(width: 70)
        }
    }
}

#Preview {
    SettingsView(viewModel: SettingsViewModel(settingsService: SettingsServiceImpl(modelContext: DataPersistenceManager.shared.makeContext())))
}