import 'package:flutter_workspace/andro_rat/debug.dart';
import 'package:mobile_number/mobile_number.dart';

void main() async {
  // await MobileNumber.requestPhonePermission;
  Debug.log(await MobileNumber.hasPhonePermission);
  // First/(default?) sim number
  final String? mobileNumber = await MobileNumber.mobileNumber;
  Debug.log(mobileNumber);
  final List<SimCard>? simCards = await MobileNumber.getSimCards;
  if (simCards != null) {
    for (var card in simCards) {
      Debug.log("--------------");
      Debug.log(card.number);
      Debug.log(card.displayName);
      Debug.log(card.carrierName);
      Debug.log(card.countryIso);
      Debug.log(card.countryPhonePrefix);
      Debug.log(card.slotIndex);
      // Debug.log(card.toMap());
      Debug.log("--------------");
    }
  }
}