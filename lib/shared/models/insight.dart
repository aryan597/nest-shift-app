enum InsightSeverity { warning, suggestion, info }

class Insight {
  final String id;
  final String title;
  final String description;
  final InsightSeverity severity;
  final String? actionDeviceId;
  final String? automationId;
  bool isResolved;

  Insight({
    required this.id,
    required this.title,
    required this.description,
    required this.severity,
    this.actionDeviceId,
    this.automationId,
    this.isResolved = false,
  });

  factory Insight.fromJson(Map<String, dynamic> json) => Insight(
        id: json['id'] as String? ?? '',
        title: json['title'] as String? ?? 'Insight',
        description: json['description'] as String? ?? '',
        severity: _parseSeverity(json['severity'] as String?),
        actionDeviceId: json['action_device_id'] as String?,
        automationId: json['automation_id'] as String?,
        isResolved: false,
      );

  static InsightSeverity _parseSeverity(String? s) {
    switch (s) {
      case 'warning':
        return InsightSeverity.warning;
      case 'suggestion':
        return InsightSeverity.suggestion;
      case 'info':
      default:
        return InsightSeverity.info;
    }
  }

  bool get isSuggestion => severity == InsightSeverity.suggestion;
  bool get isWarning => severity == InsightSeverity.warning;
}

List<Insight> demoInsights() => [
      Insight(
        id: 'i1',
        title: 'Living Room Light Left On',
        description: 'Living room light has been on for 6+ hours with no motion detected.',
        severity: InsightSeverity.warning,
        actionDeviceId: 'd1',
      ),
      Insight(
        id: 'i2',
        title: 'Automate Morning Routine',
        description: 'You turn on the kitchen switch every day at 7am — want to automate this?',
        severity: InsightSeverity.suggestion,
        automationId: 'a2',
      ),
      Insight(
        id: 'i3',
        title: 'Door Sensor Offline',
        description: 'Entrance door sensor has been offline for 15 minutes.',
        severity: InsightSeverity.info,
      ),
    ];
