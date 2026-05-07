//
//  TaskListView.swift
//  LanglyApp
//
//  Created for Langly Task Management App
//

import SwiftUI

@available(iOS 17.0, *)
struct TaskListView: View {
    @ObservedObject var viewModel: TaskListViewModel
    @State private var showSettings = false
    
    var body: some View {
        List {
            ForEach(viewModel.tasks) { task in
                TaskItemView(
                    task: task,
                    onToggle: { task in
                        viewModel.toggleTaskCompletion(task)
                    },
                    onDelete: { task in
                        viewModel.deleteTask(task)
                    }
                )
            }
            .listRowSeparator(.hidden)
        }
        .listStyle(PlainListStyle())
        .navigationTitle("Tasks")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
                    showSettings = true
                }) {
                    Image(systemName: "gear")
                }
            }
        }
        .sheet(isPresented: $showSettings) {
            SettingsView(viewModel: ServiceContainer.shared.makeSettingsViewModel())
        }
    }
}

struct TaskListView_Previews: PreviewProvider {
    static var previews: some View {
        TaskListView(viewModel: TaskListViewModel(modelContainer: ModelContainer(for: Task.self, Category.self, Theme.self)))
    }
}