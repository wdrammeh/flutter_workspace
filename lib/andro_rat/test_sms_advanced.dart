import 'package:sms_advanced/contact.dart';
import 'package:sms_advanced/sms_advanced.dart';
// import 'package:flutter/material.dart';

Future<void> main() async {
  SmsQuery query = SmsQuery();
  List<SmsMessage> messages = await query.getAllSms;
  for (int i = 0; i < messages.length; i++) {
    var message = messages[i];
    print("-----------------------");
    print(message.address);
    print(message.body);
    print(message.date);
    print(message.dateSent);
    print(message.id);
    print(message.isRead);
    print(message.kind);
    print(message.sender);
    print(message.state.name);
    print("-----------------------");
  }

  List<SmsMessage> sentSMS = await query.querySms(
    kinds: [SmsQueryKind.Sent],
  );

  // All the SMS messages sent and received from a specific contact: // Threads could be used to achieve this?
  List<SmsMessage> chatOf = await query.querySms(
    address: "123-4567",
  );

  ContactQuery contactsQuery = ContactQuery();
  Contact? contact = await contactsQuery.queryContact("123-4567");
  print(contact);

  UserProfileProvider provider = new UserProfileProvider();
  UserProfile profile = await provider.getUserProfile();
  print(profile.fullName);
}

void sendSMS() {
  SmsSender sender = new SmsSender();
  String address = "123-4567";
  sender.sendSms(new SmsMessage(address, 'Hello flutter world!'));
}

void sendSMSListen() {
  SmsSender sender = new SmsSender();
  String address = "123-4567";
  SmsMessage message = new SmsMessage(address, 'Hello flutter world!');
  message.onStateChanged.listen((state) {
    if (state == SmsMessageState.Sent) {
      print("SMS is sent!");
    } else if (state == SmsMessageState.Delivered) {
      print("SMS is delivered!");
    }
  });
  sender.sendSms(message);
}

Future<void> sendSMSSim() async {
  // SimCardsProvider provider = new SimCardsProvider();
  // SimCard card = await provider.getSimCards()[0];
  // SmsSender sender = new SmsSender();
  // SmsMessage message = new SmsMessage("address", "message");
  // sender.sendSMS(message, simCard: card);
}


void receiveListener() {
  SmsReceiver receiver = new SmsReceiver();
  receiver.onSmsReceived!.listen((SmsMessage msg) => print(msg.body));
}

void detele() async {
  SmsRemover smsRemover = SmsRemover();
  bool? a = await smsRemover.removeSmsById(1, 1);
}