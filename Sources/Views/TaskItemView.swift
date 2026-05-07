//
//  TaskItemView.swift
//  LanglyApp
//
//  Created for Langly Task Management App
//

import SwiftUI

@available(iOS 17.0, *)
struct TaskItemView: View {
    let task: Task
    let onToggle: (Task) -> Void
    let onDelete: (Task) -> Void
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            // Completion indicator
            Button(action: {
                onToggle(task)
            }) {
                Image(systemName: task.isCompleted ? "checkmark.circle.fill" : "circle")
                    .foregroundColor(task.isCompleted ? .green : .gray)
                    .font(.title2)
            }
            
            // Task details
            VStack(alignment: .leading, spacing: 4) {
                Text(task.title)
                    .font(.headline)
                    .strikethrough(task.isCompleted)
                    .lineLimit(2)
                
                if let description = task.description, !description.isEmpty {
                    Text(description)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                }
                
                HStack(spacing: 8) {
                    if let dueDate = task.dueDate {
                        Text(formatDate(dueDate))
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                
                    if let category = task.category {
                        Text(category.name)
                            .font(.caption)
                            .foregroundColor(.blue)
                    }
                }
            }
            
            Spacer()
            
            // Delete button
            Button(action: {
                onDelete(task)
            }) {
                Image(systemName: "trash")
                    .foregroundColor(.red)
                    .font(.caption)
            }
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 4)
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        return formatter.string(from: date)
    }
}

struct TaskItemView_Previews: PreviewProvider {
    static var previews: some View {
        let task = Task(title: "Sample Task", description: "Task description", dueDate: Date())
        TaskItemView(task: task, onToggle: { _ in }, onDelete: { _ in })
    }
}