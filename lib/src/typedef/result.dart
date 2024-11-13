/// Result is [Ok] or [Err]
sealed class Result<T, E> {
  bool get isErr => !isOk;
  bool get isOk => !isErr;

  /// ok value
  T get ok => throw Exception('$this is not ok');

  /// error value
  E get err => throw Exception('$this is not err');

  Result();

  @override
  String toString();
}

/// [Result] is Ok
final class Ok<T, E> extends Result<T, E> {
  final T _ok;

  Ok(this._ok);

  @override
  bool get isOk => true;

  @override
  T get ok => _ok;

  @override
  String toString() => 'Ok($_ok)';
}

/// [Result] is Err
final class Err<T, E> extends Result<T, E> {
  final E _err;

  Err(this._err);

  @override
  bool get isErr => true;

  @override
  E get err => _err;

  @override
  String toString() => 'Err($_err)';
}
