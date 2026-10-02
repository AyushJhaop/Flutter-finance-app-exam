import 'package:flutter_test/flutter_test.dart';
import 'package:fintrack/models/transaction_model.dart';
import 'package:fintrack/services/categorisation_service.dart';

void main() {
  late CategorisationService service;

  setUp(() {
    service = CategorisationService();
  });

  group('CategorisationService', () {
    test('categorises Swiggy and Zomato as food', () {
      expect(service.categorise('Swiggy'), equals(TransactionCategory.food));
      expect(service.categorise('Zomato Delivery'), equals(TransactionCategory.food));
      expect(service.categorise('Starbucks Coffee'), equals(TransactionCategory.food));
    });

    test('categorises Amazon and Flipkart as shopping', () {
      expect(service.categorise('Amazon India'), equals(TransactionCategory.shopping));
      expect(service.categorise('Flipkart Internet'), equals(TransactionCategory.shopping));
      expect(service.categorise('Myntra Designs'), equals(TransactionCategory.shopping));
    });

    test('categorises Uber and Ola as travel', () {
      expect(service.categorise('Uber Rides'), equals(TransactionCategory.travel));
      expect(service.categorise('Ola Cabs'), equals(TransactionCategory.travel));
      expect(service.categorise('Shell Petrol Pump'), equals(TransactionCategory.travel));
    });

    test('categorises Netflix and Spotify as entertainment', () {
      expect(service.categorise('Netflix Subscription'), equals(TransactionCategory.entertainment));
      expect(service.categorise('Spotify India'), equals(TransactionCategory.entertainment));
      expect(service.categorise('BookMyShow Cinema'), equals(TransactionCategory.entertainment));
    });

    test('categorises Airtel and Jio as bills', () {
      expect(service.categorise('Airtel Prepaid'), equals(TransactionCategory.bills));
      expect(service.categorise('Jio Fiber Broadband'), equals(TransactionCategory.bills));
      expect(service.categorise('BESCOM Electricity'), equals(TransactionCategory.bills));
    });

    test('categorises unrecognized merchants as other', () {
      expect(service.categorise('Unknown Merchant XYZ'), equals(TransactionCategory.other));
    });
  });
}
