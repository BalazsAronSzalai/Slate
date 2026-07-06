import SwiftUI
import SwiftData
import SlateCore

struct ProjectDetailScreen: View {
    @Bindable var project: Project

    var body: some View {
        List {
            if !project.logline.isEmpty {
                Section {
                    Text(project.logline)
                        .font(.body)
                        .foregroundStyle(.secondary)
                }
            }

            Section(String(localized: "Phases")) {
                ForEach(sortedPhases) { phase in
                    HStack {
                        Text(phase.name)
                        Spacer()
                        Text(phase.kind.rawValue)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
            }

            Section(String(localized: "Drafts")) {
                if drafts.isEmpty {
                    Text(String(localized: "No drafts yet"))
                        .foregroundStyle(.secondary)
                } else {
                    ForEach(drafts) { draft in
                        VStack(alignment: .leading, spacing: 2) {
                            Text(draft.label.isEmpty ? "Draft \(draft.versionNumber)" : draft.label)
                                .font(.headline)
                            if !draft.notesSummaryCache.isEmpty {
                                Text(draft.notesSummaryCache)
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                }
            }
        }
        .navigationTitle(project.title)
    }

    private var sortedPhases: [Phase] {
        (project.phases ?? []).sorted { $0.sortOrder < $1.sortOrder }
    }

    private var drafts: [Draft] {
        (project.drafts ?? []).sorted { $0.versionNumber > $1.versionNumber }
    }
}

#Preview {
    NavigationStack {
        ProjectDetailScreen(project: PreviewData.sampleProject())
    }
    .modelContainer(PreviewData.container())
}
