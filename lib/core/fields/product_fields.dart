class AppProductFields {
  const AppProductFields._();

  static const barcode = 'barcode';
  static const name = 'name';
  static const brand = 'brand';
  static const quantity = 'quantity';
  static const imageUrl = 'image_url';
  static const categories = 'categories';
  static const nutriscore = 'nutriscore';
  static const novaGroup = 'nova_group';
  static const ecoscore = 'ecoscore';
  static const rawJson = 'raw_json';
  static const source = 'source';
  static const status = 'status';
  static const fetchedAt = 'fetched_at';
  static const createdAt = 'created_at';
  static const updatedAt = 'updated_at';
}

class AppProductStatus {
  const AppProductStatus._();

  static const found = 'found';
  static const notFound = 'not_found';
  static const error = 'error';
}
