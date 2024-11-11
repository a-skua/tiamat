/// Result: ok or error
abstract class Result<T, E> {
  bool get isError => !isOk;
  bool get isOk => !isError;

  /// ok value
  T get ok;

  /// error value
  E get error;

  Result();

  @override
  String toString();

  /// make ok
  factory Result.ok(T ok) {
    return _Ok<T, E>(ok);
  }

  /// make err
  factory Result.err(E err) {
    return _Err<T, E>(err);
  }
}

/// Result: ok
class _Ok<T, E> extends Result<T, E> {
  final T _ok;

  _Ok(this._ok);

  @override
  bool get isOk => true;

  @override
  T get ok => _ok;

  @override
  E get error => throw Exception('is not error');

  @override
  String toString() => 'Ok($_ok)';
}

/// Result: err
class _Err<T, E> extends Result<T, E> {
  final E _error;

  _Err(this._error);

  @override
  bool get isError => true;

  @override
  T get ok => throw Exception('is not ok');

  @override
  E get error => _error;

  @override
  String toString() => 'Err($_error)';
}