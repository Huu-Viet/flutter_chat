import 'package:bloc/bloc.dart';
import 'package:flutter_chat/features/chat/domain/usecases/get_sticker_packages_usecase.dart';
import 'package:flutter_chat/features/chat/domain/usecases/get_stickers_in_package_usecase.dart';
import 'package:flutter_chat/features/chat/export.dart';

class StickerPickerCubit extends Cubit<int> {
  final GetStickerPackagesUseCase getStickerPackagesUseCase;
  final GetStickersInPackageUseCase getStickersInPackageUseCase;

  StickerPickerCubit({
    required this.getStickerPackagesUseCase,
    required this.getStickersInPackageUseCase,
  }) : super(0);

  Future<List<StickerPackage>> loadPackages() async {
    final result = await getStickerPackagesUseCase();
    return result.fold(
      (failure) => throw Exception(failure.message),
      (packages) => packages,
    );
  }

  Future<List<StickerItem>> loadStickers(String packageId) async {
    final result = await getStickersInPackageUseCase(packageId);
    return result.fold(
      (failure) => throw Exception(failure.message),
      (stickers) => stickers,
    );
  }
}
