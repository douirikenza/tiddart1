import '../models/product_model.dart';

void main() {
  void testPrice(String testName, String inputPrice) {
    final product = ProductModel.fromMap({
      'name': 'Test Product',
      'price': inputPrice,
      'image': 'test.jpg',
      'description': 'Test description',
      'artisan': 'Test Artisan',
      'category': 'Test',
    }, 'test-id');

    print('Test: $testName (Input: $inputPrice)');
    print('Prix formaté: ${product.getFormattedPrice()}');
    print('Prix double: ${product.getPriceAsDouble()}');
    print('Prix stocké: ${product.toMap()['price']}\n');
  }

  // Test des différents formats de prix
  testPrice('Prix entier simple', '8');
  testPrice('Prix avec décimales', '12.50');
  testPrice('Prix avec TND', '150.00 TND');
  testPrice('Prix avec espaces', ' 25.75 ');
  testPrice('Prix avec virgule', '8,50');
  testPrice('Prix avec virgule et espaces', ' 10,75 ');
  testPrice('Prix avec TND et virgule', '45,90 TND');
  testPrice('Grand nombre avec virgule', '1.234,56');
  testPrice('Prix à zéro', '0');
  testPrice('Prix vide', '');
  testPrice('Prix invalide', 'abc');
} 