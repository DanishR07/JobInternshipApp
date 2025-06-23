class Job {
  String id;
  String userid;
  String? image;
  String jobtitle;
  String companyname;
  String location;
  String salary;
  String description;

  Job(
    this.id,
    this.userid,
    this.jobtitle,
    this.companyname,
    this.location,
    this.salary,
    this.description,
  );

  static Job fromMap(Map<String, dynamic> map) {
    Job j = Job(
      map['id'],
      map['userid'],
      map['jobtitle'],
      map['companyname'],
      map['location'],
      map['salary'],
      map['description'],
    );
    j.image = map['image'];
    return j;
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userid': userid,
      'image': image,
      'jobtitle': jobtitle,
      'companyname': companyname,
      'location': location,
      'salary': salary,
      'description': description,
    };
  }
}
