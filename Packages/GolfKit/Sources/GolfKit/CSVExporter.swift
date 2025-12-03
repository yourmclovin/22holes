import Foundation

public enum CSVExporter {
    public static func rowsToCSV(_ rows: [ShotRecordModel]) -> String {
        var out = "id,club,distanceMeters,windSpeedMps,windDirDeg,lie,latitude,longitude,holeID,timestamp\n"
        for r in rows {
            let line = [r.id.uuidString,
                        r.club,
                        String(r.distanceMeters),
                        String(r.windSpeedMps),
                        String(r.windDirDeg),
                        r.lieType ?? "",
                        r.latitude.map { String($0) } ?? "",
                        r.longitude.map { String($0) } ?? "",
                        r.holeID?.uuidString ?? "",
                        ISO8601DateFormatter().string(from: r.timestamp)]
                .map { escapeCSV($0) }
                .joined(separator: ",")
            out += line + "\n"
        }
        return out
    }

    private static func escapeCSV(_ value: String) -> String {
        if value.contains(",") || value.contains("\"") || value.contains("\n") {
            let escaped = value.replacingOccurrences(of: "\"", with: "\"\"")
            return "\"\(escaped)\""
        }
        return value
    }
}
