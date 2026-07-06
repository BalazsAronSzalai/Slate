import SwiftUI
import SwiftData
import SlateCore

struct ProjectsScreen: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Project.sortOrder) private var projects: [Project]
    @State private var isCreatingProject = false

    var body: some View {
        NavigationStack {
            Group {
                if projects.isEmpty {
                    ContentUnavailableView {
                        Label(String(localized: "No projects yet"), systemImage: "film.stack")
                    } description: {
                        Text(String(localized: "Create a project to track drafts, milestones, and feedback."))
                    } actions: {
                        Button(String(localized: "New project")) { isCreatingProject = true }
                    }
                } else {
                    List(projects) { project in
                        NavigationLink {
                            ProjectDetailScreen(project: project)
                        } label: {
                            ProjectRow(project: project)
                        }
                    }
                }
            }
            .navigationTitle(String(localized: "Projects"))
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        isCreatingProject = true
                    } label: {
                        Label(String(localized: "New project"), systemImage: "plus")
                    }
                }
            }
            .sheet(isPresented: $isCreatingProject) {
                NewProjectSheet()
            }
        }
    }
}

private struct ProjectRow: View {
    let project: Project

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(project.title)
                .font(.headline)
            if !project.logline.isEmpty {
                Text(project.logline)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .lineLimit(2)
            }
        }
        .padding(.vertical, 2)
    }
}

private struct NewProjectSheet: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    @State private var title = ""
    @State private var logline = ""

    var body: some View {
        NavigationStack {
            Form {
                TextField(String(localized: "Title"), text: $title)
                TextField(String(localized: "Logline"), text: $logline, axis: .vertical)
                    .lineLimit(2...4)
            }
            .navigationTitle(String(localized: "New project"))
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(String(localized: "Cancel")) { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button(String(localized: "Create")) { createProject() }
                        .disabled(title.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
        }
        .presentationDetents([.medium, .large])
    }

    private func createProject() {
        let project = Project(
            title: title.trimmingCharacters(in: .whitespaces),
            logline: logline.trimmingCharacters(in: .whitespaces)
        )
        modelContext.insert(project)

        let phases = PreviewData.samplePhases(for: project)
        phases.forEach { modelContext.insert($0) }

        do {
            try modelContext.save()
            dismiss()
        } catch {
            assertionFailure("Failed to save project: \(error)")
        }
    }
}

#Preview {
    ProjectsScreen()
        .modelContainer(PreviewData.container())
}
