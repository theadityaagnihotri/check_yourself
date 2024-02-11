class ChecklistItem {
  final String title;
  final List<String> options;
  final List<bool> checked;

  ChecklistItem({
    required this.title,
    required this.options,
    List<bool>? checked,
  }) : this.checked = checked ?? List<bool>.filled(options.length, false);

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'options': options,
      'checked': checked,
    };
  }

  factory ChecklistItem.fromJson(Map<String, dynamic> json) {
    return ChecklistItem(
      title: json['title'],
      options: List<String>.from(json['options']),
      checked: List<bool>.from(
          json['checked'] ?? List.filled(json['options'].length, false)),
    );
  }
}
