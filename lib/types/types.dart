import 'package:flutter_workspace/types/planets.dart';
import 'package:flutter_workspace/types/spacecraft.dart';

void main() {
  // Classes
  var voyager = Spacecraft('Voyager 1', DateTime(1977, 9, 5));
  voyager.describe();

  var voyager3 = Spacecraft.unlaunched('Voyager 3');
  voyager3.describe();
  
  // Enums
  final yourPlanet = Planet.earth;

  if (!yourPlanet.isGiant) {
    print('Your planet is not a "giant planet".');
  }
  
}
