// See installation notes below regarding AndroidManifest.xml and Info.plist
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:flutter/material.dart';

Future<void> main() async {
  // Request contact permission
  if (await FlutterContacts.requestPermission()) {
// Get all contacts (lightly fetched)
    List<Contact> contacts = await FlutterContacts.getContacts();

// Get all contacts (fully fetched)
    contacts = await FlutterContacts.getContacts(
        withProperties: true, withPhoto: true);

// Get contact with specific ID (fully fetched)
    Contact? contact = await FlutterContacts.getContact(contacts.first.id);

// Insert new contact
    final newContact = Contact()
      ..name.first = 'John'
      ..name.last = 'Smith'
      ..phones = [Phone('555-123-4567')];
    await newContact.insert();

    if (contact == null) {
      return;
    }

// Update contact
    contact.name.first = 'Bob';
    await contact.update();

// Delete contact
    await contact.delete();

// Open external contact app to view/edit/pick/insert contacts.
    await FlutterContacts.openExternalView(contact.id);
    await FlutterContacts.openExternalEdit(contact.id);
    final externalPicked = await FlutterContacts.openExternalPick();
    final externalInsert = await FlutterContacts.openExternalInsert();

// Listen to contact database changes
    FlutterContacts.addListener(() => print('Contact DB changed'));

// Create a new group (iOS) / label (Android).
    await FlutterContacts.insertGroup(Group('', 'Coworkers'));

// Export contact to vCard
    String vCard = contact.toVCard();

// Import contact from vCard
    contact = Contact.fromVCard('BEGIN:VCARD\n'
        'VERSION:3.0\n'
        'N:;Joe;;;\n'
        'TEL;TYPE=HOME:123456\n'
        'END:VCARD');
  }
}
