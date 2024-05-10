abstract class NetworkException implements Exception {}

final class CouldNotConnect extends NetworkException {}

final class BadResponse extends NetworkException {}

final class FailedToRefresh extends NetworkException {}
