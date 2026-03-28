class AutomationTrigger {
  final String type; // time | device_state | scene
  final Map<String, dynamic> config;
  const AutomationTrigger({required this.type, required this.config});

  factory AutomationTrigger.fromJson(Map<String, dynamic> json) =>
      AutomationTrigger(
        type: json['type'] as String? ?? 'time',
        config: (json['config'] as Map<String, dynamic>?) ?? {},
      );

  Map<String, dynamic> toJson() => {'type': type, 'config': config};
}

class AutomationAction {
  final String type; // device_command | scene
  final Map<String, dynamic> config;
  const AutomationAction({required this.type, required this.config});

  factory AutomationAction.fromJson(Map<String, dynamic> json) =>
      AutomationAction(
        type: json['type'] as String? ?? 'device_command',
        config: (json['config'] as Map<String, dynamic>?) ?? {},
      );

  Map<String, dynamic> toJson() => {'type': type, 'config': config};
}

class Automation {
  final String id;
  final String name;
  final AutomationTrigger trigger;
  final AutomationAction action;
  final bool enabled;

  const Automation({
    required this.id,
    required this.name,
    required this.trigger,
    required this.action,
    required this.enabled,
  });

  factory Automation.fromJson(Map<String, dynamic> json) => Automation(
        id: json['id'] as String,
        name: json['name'] as String? ?? 'Automation',
        trigger: AutomationTrigger.fromJson(
          (json['trigger'] as Map<String, dynamic>?) ?? {'type': 'time', 'config': {}},
        ),
        action: AutomationAction.fromJson(
          (json['action'] as Map<String, dynamic>?) ?? {'type': 'device_command', 'config': {}},
        ),
        enabled: json['enabled'] as bool? ?? false,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'trigger': trigger.toJson(),
        'action': action.toJson(),
        'enabled': enabled,
      };

  Automation copyWith({
    String? id,
    String? name,
    AutomationTrigger? trigger,
    AutomationAction? action,
    bool? enabled,
  }) =>
      Automation(
        id: id ?? this.id,
        name: name ?? this.name,
        trigger: trigger ?? this.trigger,
        action: action ?? this.action,
        enabled: enabled ?? this.enabled,
      );

  String get triggerDescription {
    switch (trigger.type) {
      case 'time':
        return 'At ${trigger.config['time'] ?? '--:--'}';
      case 'device_state':
        return 'When device changes';
      case 'scene':
        return 'On scene activate';
      default:
        return trigger.type;
    }
  }
}

List<Automation> demoAutomations() => [
      Automation(
        id: 'a1',
        name: 'Night Mode',
        trigger: const AutomationTrigger(type: 'time', config: {'time': '22:00'}),
        action: const AutomationAction(type: 'scene', config: {'scene': 'night'}),
        enabled: true,
      ),
      Automation(
        id: 'a2',
        name: 'Morning Routine',
        trigger: const AutomationTrigger(type: 'time', config: {'time': '07:00'}),
        action: const AutomationAction(type: 'device_command', config: {'device_id': 'd1', 'state': true}),
        enabled: false,
      ),
    ];
