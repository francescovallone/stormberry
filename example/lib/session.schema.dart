// GENERATED CODE - DO NOT MODIFY BY HAND

// ignore_for_file: type=lint
// dart format off

import 'package:stormberry/stormberry.dart' as sb;
import 'models/account.dart';
import 'models/address.dart';
import 'models/company.dart';
import 'models/invoice.dart';
import 'models/party.dart';

extension AllRepositories on sb.Session {

  Map<Type, sb.ModelRepository> get allRepositories => {
    AccountRepository: accounts,
    BillingAddressRepository: billingAddresses,
    CompanyRepository: companies,
    InvoiceRepository: invoices,
    PartyRepository: parties,
  };
}

