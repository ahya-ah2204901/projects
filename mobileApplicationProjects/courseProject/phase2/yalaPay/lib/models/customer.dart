class Customer {
  final String id;
  final String companyName;
  final Address address;
  final ContactDetails contactDetails;

  Customer({
    required this.id,
    required this.companyName,
    required this.address,
    required this.contactDetails,
  });

  factory Customer.fromMap(Map<String, dynamic> map) {
    return Customer(
      id: map['id'],
      companyName: map['companyName'],
      address: Address.fromMap(map['address']),
      contactDetails: ContactDetails.fromMap(map['contactDetails']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'companyName': companyName,
      'companyNameLower' : companyName.toLowerCase(),
      'address': address.toMap(),
      'contactDetails': contactDetails.toMap()
    };
  }
}

class Address {
  final String street;
  final String city;
  final String country;

  Address({
    required this.street,
    required this.city,
    required this.country,
  });

  factory Address.fromMap(Map<String, dynamic> map) {
    return Address(
      street: map['street'],
      city: map['city'],
      country: map['country'],
    );
  }

  Map<String, dynamic> toMap() {
    return {'street': street, 'city': city, 'country': country};
  }
}

class ContactDetails {
  final String firstName;
  final String lastName;
  final String email;
  final String mobile;

  ContactDetails({
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.mobile,
  });

  factory ContactDetails.fromMap(Map<String, dynamic> map) {
    return ContactDetails(
      firstName: map['firstName'],
      lastName: map['lastName'],
      email: map['email'],
      mobile: map['mobile'],
    );
  }
  Map<String, dynamic> toMap() {
    return {
      'firstName': firstName,
      'firstNameLower' : firstName.toLowerCase(),
      'lastName': lastName,
      'email': email,
      'mobile': mobile
    };
  }
}
