//
//  TaskListView.swift
//  LanglyApp
//
//  Created for Langly Task Management App
//

import SwiftUI

@available(iOS 17.0, *)
struct TaskListView: View {
    @ObservedObject var viewModel: HomeScreenViewModel
    
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
    }
}

struct TaskListView_Previews: PreviewProvider {
    static var previews: some View {
        TaskListView(viewModel: HomeScreenViewModel(taskRepository: TaskRepositoryImpl(modelContext: ModelContext(modelContainer: ModelContainer(for: Task.self, Category.self, Theme.self)))))
    }
}