

class hdd {
  int? age;
  int? gender;
  int? chestPainType;
  int? maxHR;
  int? exerciseAngina;
  int? fastingBS;

  hdd(
      {this.age,
      this.gender,
      this.chestPainType,
      this.maxHR,
      this.exerciseAngina,
      this.fastingBS});

  hdd.fromJson(Map<String, dynamic> json) {
    age = json['age'];
    gender = json['gender'];
    chestPainType = json['ChestPainType'];
    maxHR = json['MaxHR'];
    exerciseAngina = json['ExerciseAngina'];
    fastingBS = json['FastingBS'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['age'] = age;
    data['gender'] = gender;
    data['ChestPainType'] = chestPainType;
    data['MaxHR'] = maxHR;
    data['ExerciseAngina'] = exerciseAngina;
    data['FastingBS'] = fastingBS;
    return data;
  }
}
