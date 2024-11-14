/// Result is [Ok] or [Err]
sealed class Result<T, E> {
  bool get isErr => !isOk;
  bool get isOk => !isErr;

  /// ok value
  T get ok => throw Exception('$this is not ok');

  /// error value
  E get err => throw Exception('$this is not err');

  const Result();

  @override
  String toString();
}

/// [Result] is Ok
final class Ok<T, E> extends Result<T, E> {
  final T _ok;

  const Ok(this._ok) : super();

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

  const Err(this._err) : super();

  @override
  bool get isErr => true;

  @override
  E get err => _err;

  @override
  String toString() => 'Err($_err)';
}
