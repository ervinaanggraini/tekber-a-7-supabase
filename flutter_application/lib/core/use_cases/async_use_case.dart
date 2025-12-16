abstract class AsyncUseCase<ReturnType, Params> {
  Future<ReturnType> execute(Params params);
}
