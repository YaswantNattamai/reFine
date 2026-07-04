class AppInfo {
  final String name;
  final String packageName;

  AppInfo({
    required this.name,
    required this.packageName,
  });

  factory AppInfo.fromMap(Map<dynamic, dynamic> map) {
    return AppInfo(
      name: map['name'] as String? ?? '',
      packageName: map['packageName'] as String? ?? '',
    );
  }

  Map<String, String> toMap() {
    return {
      'name': name,
      'packageName': packageName,
    };
  }
}
