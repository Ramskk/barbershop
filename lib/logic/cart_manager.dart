class CartItem {
  final String type; // service / product
  final int id;
  final String name;
  final int price;
  int qty;

  CartItem({
    required this.type,
    required this.id,
    required this.name,
    required this.price,
    required this.qty,
  });

  int get subtotal => price * qty;
}

class CartManager {
  final List<CartItem> _items = [];

  List<CartItem> get items => _items;

  /// ✅ TRUE jika ADA minimal 1 layanan
  bool get hasService =>
      _items.any((e) => e.type == 'service');

  /// ✅ Minimal 1 item (service / product)
  bool get isValid => _items.isNotEmpty;

  /// ✅ Total transaksi
  int get total =>
      _items.fold<int>(0, (sum, e) => sum + e.subtotal);

  /// 🔥 FIX UTAMA: LAYANAN BISA BANYAK JENIS (QTY = 1)
  void addService(int id, String name, int price) {
    // ❌ JANGAN hapus semua service
    final exists = _items.any(
          (e) => e.type == 'service' && e.id == id,
    );

    if (exists) return; // ❌ service yang sama tidak boleh dobel

    _items.add(CartItem(
      type: 'service',
      id: id,
      name: name,
      price: price,
      qty: 1, // selalu 1
    ));
  }

  /// ✅ PRODUK: BISA BANYAK + QTY
  void addProduct(int id, String name, int price) {
    final index = _items.indexWhere(
          (e) => e.type == 'product' && e.id == id,
    );

    if (index >= 0) {
      _items[index].qty++;
    } else {
      _items.add(CartItem(
        type: 'product',
        id: id,
        name: name,
        price: price,
        qty: 1,
      ));
    }
  }

  /// ✅ HAPUS ITEM
  void removeItem(CartItem item) {
    _items.remove(item);
  }

  /// ✅ RESET CART
  void clear() => _items.clear();
}
