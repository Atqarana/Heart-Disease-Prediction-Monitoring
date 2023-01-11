class ListData {
  ListData({
    this.imagePath = '',
    this.titleTxt = '',
    this.startColor = '',
    this.endColor = '',
    this.meals,
    this.kacl = '',
    this.unit = '',
  });
  String imagePath;
  String titleTxt;
  String startColor;
  String endColor;
  List<String>? meals;
  String kacl;
  String unit;

  static List<ListData> tabIconsList = <ListData>[
    ListData(
      imagePath: 'assets/images/HR.png',
      titleTxt: 'Heart Rate',
      kacl: '60 - 100',
      unit: 'BPM',
      meals: <String>['Normal,', 'Resting', 'Heart Rate is'],
      startColor: '#FA7D82',
      endColor: '#FFB295',
    ),
    ListData(
      imagePath: 'assets/images/exercise.png',
      titleTxt: 'Activity',
      kacl: '30 - 60',
      unit: 'Minutes',
      meals: <String>['Recommended', 'Activity Zone,', 'Time'],
      startColor: '#738AE6',
      endColor: '#5C5EDD',
    ),
    ListData(
      imagePath: 'assets/images/foot.png',
      titleTxt: 'Steps',
      kacl: '5K - 6K',
      unit: ' Steps',
      meals: <String>['Recommended', 'foot steps', 'Everday'],
      startColor: '#FE95B6',
      endColor: '#FF5287',
    ),
    ListData(
      imagePath: 'assets/images/sleep.png',
      titleTxt: 'Sleep',
      kacl: '6 - 8',
      unit: 'Hours / day',
      meals: <String>['Recommended', 'Sleep', 'Everyday'],
      startColor: '#6F72CA',
      endColor: '#1E1466',
    ),
  ];
}
