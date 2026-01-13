import SwiftUI
import SwiftData
import Charts

struct StatsView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var notes: [Note]
    @Query private var tags: [Tag]

    private var now: Date { Date() }
    private var weekAgo: Date { Calendar.current.date(byAdding: .day, value: -7, to: now) ?? now }
    private var monthAgo: Date { Calendar.current.date(byAdding: .day, value: -30, to: now) ?? now }

    var totalNotes: Int {
        notes.count
    }

    var weekNotes: Int {
        notes.filter { $0.createdAt > weekAgo }.count
    }

    var topTags: [Tag] {
        Array(tags.sorted(by: { $0.useCount > $1.useCount }).prefix(5))
    }

    var totalImages: Int {
        notes.reduce(0) { $0 + $1.images.count }
    }

    var avgImagesPerNote: Double {
        guard !notes.isEmpty else { return 0 }
        return Double(totalImages) / Double(notes.count)
    }

    var last30DaysData: [(Date, Int)] {
        let calendar = Calendar.current
        var data: [Date: Int] = [:]

        // Initialize all days with 0
        for i in 0..<30 {
            if let date = calendar.date(byAdding: .day, value: -i, to: now) {
                let dayStart = calendar.startOfDay(for: date)
                data[dayStart] = 0
            }
        }

        // Count notes per day
        for note in notes where note.createdAt > monthAgo {
            let dayStart = calendar.startOfDay(for: note.createdAt)
            data[dayStart, default: 0] += 1
        }

        return data.sorted { $0.key < $1.key }.map { ($0.key, $0.value) }
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // Total notes
                    StatCard(title: "Total Notes", value: "\(totalNotes)", icon: "text.bubble")

                    // This week
                    StatCard(title: "This Week", value: "\(weekNotes)", icon: "calendar")

                    // Images
                    StatCard(title: "Total Images", value: "\(totalImages)", icon: "photo")
                    StatCard(title: "Avg Images/Note", value: String(format: "%.1f", avgImagesPerNote), icon: "chart.bar")

                    // Top tags
                    if !topTags.isEmpty {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Top Tags")
                                .font(.headline)
                                .padding(.horizontal)

                            ForEach(topTags, id: \.id) { tag in
                                HStack {
                                    Circle()
                                        .fill(tag.color)
                                        .frame(width: 10, height: 10)

                                    Text(tag.name)
                                        .font(.body)

                                    Spacer()

                                    Text("\(tag.useCount)")
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                                .padding(.horizontal)
                            }
                        }
                        .padding()
                        .background(.regularMaterial)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                    }

                    // Activity chart
                    if !last30DaysData.isEmpty {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Last 30 Days")
                                .font(.headline)
                                .padding(.horizontal)

                            Chart(last30DaysData, id: \.0) { item in
                                BarMark(
                                    x: .value("Date", item.0),
                                    y: .value("Notes", item.1)
                                )
                            }
                            .frame(height: 150)
                            .padding(.horizontal)
                        }
                        .padding()
                        .background(.regularMaterial)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                }
                .padding()
            }
            .navigationTitle("Statistics")
        }
    }
}

struct StatCard: View {
    let title: String
    let value: String
    let icon: String

    var body: some View {
        HStack {
            Image(systemName: icon)
                .font(.title2)
                .foregroundStyle(.secondary)
                .frame(width: 40)

            VStack(alignment: .leading) {
                Text(title)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Text(value)
                    .font(.title)
                    .fontWeight(.bold)
            }

            Spacer()
        }
        .padding()
        .background(.regularMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: Note.self, Tag.self, configurations: config)
    return StatsView()
        .modelContainer(container)
}
