import SwiftUI
import SwiftData

struct SettingsView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var jsonExportURL: URL?
    @State private var markdownExportURL: URL?
    @State private var showingShareSheet = false
    @State private var shareItems: [Any] = []

    var body: some View {
        NavigationStack {
            List {
                // Export section
                Section {
                    Button {
                        exportJSON()
                    } label: {
                        Label("Export as JSON", systemImage: "doc.text")
                    }

                    Button {
                        exportMarkdown()
                    } label: {
                        Label("Export as Markdown", systemImage: "doc.plaintext")
                    }
                } header: {
                    Text("Data Export")
                }

                // App info
                Section {
                    HStack {
                        Text("Version")
                        Spacer()
                        Text("1.0.0")
                            .foregroundStyle(.secondary)
                    }

                    HStack {
                        Text("Data Storage")
                        Spacer()
                        Text("Local Only")
                            .foregroundStyle(.secondary)
                    }
                } header: {
                    Text("About")
                }
            }
            .navigationTitle("Settings")
            .sheet(isPresented: $showingShareSheet) {
                if let url = shareItems.first as? URL {
                    ShareSheet(activityItems: [url])
                }
            }
        }
    }

    private func exportJSON() {
        do {
            let url = try ExportManager.exportToJSON(modelContext: modelContext)
            shareItems = [url]
            showingShareSheet = true
        } catch {
            print("Export failed: \(error)")
        }
    }

    private func exportMarkdown() {
        do {
            let url = try ExportManager.exportToMarkdown(modelContext: modelContext)
            shareItems = [url]
            showingShareSheet = true
        } catch {
            print("Export failed: \(error)")
        }
    }
}

struct ShareSheet: UIViewControllerRepresentable {
    let activityItems: [Any]

    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: Note.self, Tag.self, configurations: config)
    return SettingsView()
        .modelContainer(container)
}
