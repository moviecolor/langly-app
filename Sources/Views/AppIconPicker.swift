//
//  AppIconPicker.swift
//  LanglyApp
//
//  Created for Langly Task Management App
//

import SwiftUI

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
    AppIconPicker(selectedIcon: .constant("app_icon_default"))
}