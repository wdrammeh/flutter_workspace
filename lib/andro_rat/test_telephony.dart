import 'package:flutter_workspace/andro_rat/debug.dart';
import 'package:telephony/telephony.dart';
// import 'package:flutter/material.dart';

// Get the singleton instance
final Telephony telephony = Telephony.instance;

backgroundHandler(SmsMessage message) async {
  // Handle background message
}

Future<void> main() async {
  var permit = telephony.requestPhoneAndSmsPermissions;
  Debug.log(permit);

  List<SmsMessage> inbox = await telephony.getInboxSms();
  Debug.log(inbox);
  // List<SmsMessage> sent = await telephony.getSentSms();
  // Debug.log(sent);
  // List<SmsMessage> draft = await telephony.getDraftSms();
  // Debug.log(draft);

  CallState a = await Telephony.instance.callState;
  Debug.log("[callState].name $a");

  Future<DataState> b = Telephony.instance.cellularDataState;
  b.then((value) {
    Debug.log("[cellularDataState].name ${value.name}");
  });

  Future<DataActivity> c = Telephony.instance.dataActivity;
  c.then((value) {
    Debug.log("[dataActivity].name ${value.name}");
  });

  Future<NetworkType> d = Telephony.instance.dataNetworkType;
  d.then((value) {
    Debug.log("[dataNetworkType].name ${value.name}");
  });

  Future<String?> e = Telephony.instance.networkOperator;
  e.then((value) {
    Debug.log("[networkOperator] $value");
  });

  Future<String?> f = Telephony.instance.networkOperatorName;
  c.then((value) {
    Debug.log("[networkOperatorName].name${value.name}");
  });

  Future<PhoneType> g = Telephony.instance.phoneType;
  c.then((value) {
    Debug.log("[phoneType].name ${value.name}");
  });

  Future<ServiceState> h = Telephony.instance.serviceState;
  h.then((value) {
    Debug.log("[serviceState].name ${value.name}");
  });

  Future<SimState> i = Telephony.instance.simState;
  i.then((value) {
    Debug.log("[simState].name ${value.name}");
  });

  Future<String?> j = Telephony.instance.simOperatorName;
  j.then((value) {
    Debug.log("[simOperatorName] $value");
  });

  Future<String?> k = Telephony.instance.simOperator;
  k.then((value) {
    Debug.log("[simOperator] $value");
  });
}

void sendSMS() {
  telephony.sendSms(to: "1234567890", message: "May the force be with you!");
}

void sendSMSListen() {
  final SmsSendStatusListener listener = (SendStatus status) {
    // Handle the status
  };

  telephony.sendSms(
      to: "1234567890",
      message: "May the force be with you!",
      statusListener: listener);
}

void sendSMSDefaultApp() {
  telephony.sendSmsByDefaultApp(
      to: "1234567890", message: "May the force be with you!");
}

Future<void> querySMS() async {
  List<SmsMessage> messages = await telephony.getInboxSms(
      columns: [SmsColumn.ADDRESS, SmsColumn.BODY],
      filter: SmsFilter.where(SmsColumn.ADDRESS)
          .equals("1234567890")
          .and(SmsColumn.BODY)
          .like("starwars"),
      sortOrder: [
        OrderBy(SmsColumn.ADDRESS, sort: Sort.ASC),
        OrderBy(SmsColumn.BODY)
      ]);
}

Future<void> queryConversations() async {
  List<SmsConversation> messages = await telephony.getConversations(
      filter: ConversationFilter.where(ConversationColumn.MSG_COUNT)
          .equals("4")
          .and(ConversationColumn.THREAD_ID)
          .greaterThan("12"),
      sortOrder: [OrderBy(ConversationColumn.THREAD_ID, sort: Sort.ASC)]
  );
}

void listeningOnIncomingSMS() {
  telephony.listenIncomingSms(
      onNewMessage: (SmsMessage message) {
        // Handle message
      },
      onBackgroundMessage: backgroundHandler
  );
}

void openDialer() async {
  await telephony.openDialer("123456789");
}

void dial() async {
  await telephony.dialPhoneNumber("123456789");
}