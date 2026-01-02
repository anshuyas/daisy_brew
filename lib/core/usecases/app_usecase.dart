import 'package:daisy_brew/core/error/failures.dart';
import 'package:dartz/dartz.dart';

abstract interface class UseCaseWithParams<SuccesType, Params> {
  Future<Either<Failure, SuccesType>> call(Params params);
}

abstract interface class UseCaseWithoutParams<SuccesType> {
  Future<Either<Failure, SuccesType>> call();
}
