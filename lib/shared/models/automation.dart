class AutomationTrigger {
  final String type;
  final Map<String, dynamic> config;
  const AutomationTrigger({required this.type, required this.config});

  factory AutomationTrigger.fromJson(Map<String, dynamic> json) {
    String type = 'time';
    Map<String, dynamic> config = {};
    
    if (json['trigger_type'] != null) {
      type = json['trigger_type'] as String;
    } else if (json['type'] != null) {
      type = json['type'] as String;
    }
    
    if (json['trigger_config'] != null) {
      config = json['trigger_config'] as Map<String, dynamic>;
    } else if (json['config'] != null) {
      config = json['config'] as Map<String, dynamic>;
    }
    
    return AutomationTrigger(type: type, config: config);
  }

  Map<String, dynamic> toJson() => {'trigger_type': type, 'trigger_config': config};
}

class AutomationAction {
  final String type;
  final Map<String, dynamic> config;
  const AutomationAction({required this.type, required this.config});

  factory AutomationAction.fromJson(dynamic json) {
    if (json is Map<String, dynamic>) {
      return AutomationAction(
        type: json['type'] as String? ?? 'device_control',
        config: json['command'] != null 
            ? {'command': json['command'], 'target': json['target']}
            : (json['config'] as Map<String, dynamic>?) ?? {},
      );
    }
    return const AutomationAction(type: 'device_control', config: {});
  }

  Map<String, dynamic> toJson() => {'type': type, 'command': config['command'], 'target': config['target']};
}

class Automation {
  final String id;
  final String name;
  final String? description;
  final AutomationTrigger trigger;
  final List<AutomationAction> actions;
  final bool enabled;
  final String? lastTriggered;
  final int triggerCount;

  const Automation({
    required this.id,
    required this.name,
    this.description,
    required this.trigger,
    required this.actions,
    required this.enabled,
    this.lastTriggered,
    this.triggerCount = 0,
  });

  factory Automation.fromJson(Map<String, dynamic> json) {
    List<AutomationAction> actions = [];
    if (json['actions'] != null) {
      actions = (json['actions'] as List<dynamic>)
          .map((a) => AutomationAction.fromJson(a as Map<String, dynamic>))
          .toList();
    } else if (json['action'] != null) {
      actions = [AutomationAction.fromJson(json['action'] as Map<String, dynamic>)];
    }

    String? lastTriggered;
    if (json['last_triggered'] != null) {
      lastTriggered = json['last_triggered'] as String;
    }

    return Automation(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? 'Automation',
      description: json['description'] as String?,
      trigger: AutomationTrigger.fromJson(json),
      actions: actions,
      enabled: json['enabled'] as bool? ?? false,
      lastTriggered: lastTriggered,
      triggerCount: json['trigger_count'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
        'name': name,
        'description': description ?? '',
        'trigger_type': trigger.type,
        'trigger_config': trigger.config,
        'actions': actions.map((a) => a.toJson()).toList(),
        'enabled': enabled,
      };

  Automation copyWith({
    String? id,
    String? name,
    String? description,
    AutomationTrigger? trigger,
    List<AutomationAction>? actions,
    bool? enabled,
    String? lastTriggered,
    int? triggerCount,
  }) =>
      Automation(
        id: id ?? this.id,
        name: name ?? this.name,
        description: description ?? this.description,
        trigger: trigger ?? this.trigger,
        actions: actions ?? this.actions,
        enabled: enabled ?? this.enabled,
        lastTriggered: lastTriggered ?? this.lastTriggered,
        triggerCount: triggerCount ?? this.triggerCount,
      );

  String get triggerDescription {
    switch (trigger.type) {
      case 'time':
        final cron = trigger.config['cron'];
        if (cron != null) {
          return 'Scheduled: $cron';
        }
        final time = trigger.config['time'];
        return time != null ? 'At $time' : 'Time trigger';
      case 'sensor_threshold':
        return 'Sensor threshold';
      case 'device_state':
        return 'Device state change';
      case 'mqtt':
        return 'MQTT message';
      case 'scene':
        return 'Scene trigger';
      default:
        return trigger.type;
    }
  }
}

List<Automation> demoAutomations() => [
      Automation(
        id: 'a1',
        name: 'Night Mode',
        description: 'Turn on night lights at sunset',
        trigger: const AutomationTrigger(type: 'time', config: {'cron': '0 20 * * *'}),
        actions: const [AutomationAction(type: 'device_control', config: {'command': 'turn_on', 'target': 'all_lights'})],
        enabled: true,
        triggerCount: 12,
      ),
      Automation(
        id: 'a2',
        name: 'Morning Routine',
        description: 'Start coffee machine at 7am',
        trigger: const AutomationTrigger(type: 'time', config: {'cron': '0 7 * * *'}),
        actions: const [AutomationAction(type: 'device_control', config: {'command': 'turn_on', 'target': 'coffee_machine'})],
        enabled: false,
        triggerCount: 5,
      ),
    ];