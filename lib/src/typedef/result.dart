/// Result is [Ok] or [Err]
sealed class Result<T, E> {
  bool get isErr => !isOk;
  bool get isOk => !isErr;

  /// ok value
  T get ok => throw Exception('$this is not ok');

  /// error value
  E get err => throw Exception('$this is not err');

  dynamic get unwrap;

  const Result();

  Result<U, E> map<U>(U Function(T) f) => isOk ? Ok(f(ok)) : Err(err);

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
  T get unwrap => _ok;

  @override
  String toString() => 'Ok($_ok)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Ok && other._ok == _ok;
  }

  @override
  int get hashCode => _ok.hashCode;
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
  E get unwrap => _err;

  @override
  String toString() => 'Err($_err)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Err && other._err == _err;
  }

  @override
  int get hashCode => _err.hashCode;
}
