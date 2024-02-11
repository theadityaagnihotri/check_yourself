class FirestoreChecklistItem {
  final String id;
  final String title;
  final List<String> options;
  final List<bool> checked;
  final List<String> sharedWith;

  FirestoreChecklistItem({
    required this.id,
    required this.title,
    required this.options,
    required this.checked,
    required this.sharedWith,
  });
  FirestoreChecklistItem copyWith({
    String? id,
    String? title,
    List<String>? options,
    List<bool>? checked,
    List<String>? sharedWith,
  }) {
    return FirestoreChecklistItem(
      id: id ?? this.id,
      title: title ?? this.title,
      options: options ?? this.options,
      checked: checked ?? this.checked,
      sharedWith: sharedWith ?? this.sharedWith,
    );
  }

  factory FirestoreChecklistItem.fromJson(Map<String, dynamic> json) {
    return FirestoreChecklistItem(
      id: json['id'],
      title: json['title'],
      options: List<String>.from(json['options']),
      checked: List<bool>.from(
          json['checked'] ?? List.filled(json['options'].length, false)),
      sharedWith: List<String>.from(json['sharedWith']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'options': options,
      'checked': checked,
      'sharedWith': sharedWith,
    };
  }
}
