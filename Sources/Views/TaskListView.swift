import SwiftUI

struct TaskListView: View {
    @StateObject private var viewModel: TaskListViewModel
    
    init(viewModel: TaskListViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }
    
    var body: some View {
        NavigationStack {
            if viewModel.tasks.isEmpty {
                EmptyTaskView()
            } else {
                List {
                    ForEach(viewModel.tasks) { task in
                        TaskRowView(task: task, viewModel: viewModel)
                    }
                    .onDelete(perform: deleteTasks)
                }
                .navigationTitle("Tasks")
                .toolbar {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button("Add") {
                            viewModel.addTask(title: "New Task")
                        }
                    }
                }
            }
        }
    }
    
    private func deleteTasks(offsets: IndexSet) {
        for index in offsets {
            viewModel.deleteTask(viewModel.tasks[index])
        }
    }
}

struct EmptyTaskView: View {
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "list.bullet")
                .font(.system(size: 64, weight: .thin))
                .foregroundStyle(.secondary)
            
            Text("No tasks yet")
                .font(.title2)
                .fontWeight(.medium)
            
            Text("Add your first task to get started")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding()
    }
}

struct TaskRowView: View {
    let task: Task
    let viewModel: TaskListViewModel
    
    var body: some View {
        HStack {
            Button {
                viewModel.toggleTaskCompletion(task)
            } label: {
                Image(systemName: task.isCompleted ? "checkmark.circle.fill" : "circle")
                    .foregroundColor(task.isCompleted ? .green : .primary)
                    .font(.title2)
            }
            .buttonStyle(.plain)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(task.title)
                    .fontWeight(.medium)
                    .strikethrough(task.isCompleted)
                
                if let description = task.description, !description.isEmpty {
                    Text(description)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }
            
            Spacer()
            
            Text(task.updatedAt, style: .date)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding(.vertical, 4)
        .contentShape(Rectangle())
        .onTapGesture {
            // Edit task functionality would go here
        }
    }
}

#Preview {
    let modelContainer = try! ModelContainer(for: Task.self)
    let viewModel = TaskListViewModel(modelContainer: modelContainer)
    return TaskListView(viewModel: viewModel)
}