
class Internship {
  String id;
  String title;
  String companyName;
  String? image;
  String location;
  String description;
  String stipend;
  String duration;

  Internship(
    this.id,
    this.title,
    this.companyName,
    this.location,
    this.description,
    this.stipend,
    this.duration,
  );

  static Internship fromMap(Map<String, dynamic> map) {
    Internship i= Internship(
      map['id'],
      map['title'],
      map['companyName'],
      map['location'],
      map['description'],
      map['stipend'],
      map['duration'],
    );
    i.image = map['image'];
    return i;
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'companyName': companyName,
      'image': image,
      'location': location,
      'description': description,
      'stipend': stipend,
      'duration': duration,
    };
  }
}