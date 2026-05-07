// Key-value pair for a labeled company contact field.

final class ContactEntry {
  const ContactEntry({required this.name, required this.value});

  final String name;
  final String value;

  ContactEntry copyWith({String? name, String? value}) {
    return ContactEntry(name: name ?? this.name, value: value ?? this.value);
  }
}
