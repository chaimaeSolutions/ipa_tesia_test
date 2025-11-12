class KitServiceException implements Exception {
  final String code;
  final String? serverMessage;
  KitServiceException(this.code, {this.serverMessage});
  @override
  String toString() => 'KitServiceException($code): ${serverMessage ?? ''}';
}
