class Company {
  final String name;
  final String domain;
  final String logo;

  Company({this.name, this.domain, this.logo});

  factory Company.fromJson(Map<String, dynamic> json) {
    return Company(
      name: json['name'],
      domain: json['domain'],
      logo: json['logo'] != null
          ? json['logo']
          : "https://logo.clearbit.com/flutter.io",
    );
  }
}