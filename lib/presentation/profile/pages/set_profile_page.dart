import 'dart:developer';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_chat/app/media_providers.dart';
import 'package:flutter_chat/core/utils/file_utils.dart';
import 'package:flutter_chat/features/auth/domain/entities/user.dart';
import 'package:flutter_chat/l10n/app_localizations.dart';
import 'package:flutter_chat/presentation/profile/blocs/set_profile_bloc/set_profile_bloc.dart';
import 'package:flutter_chat/presentation/profile/widgets/info_input.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_chat/presentation/profile/providers/set_profile_bloc_provider.dart';

class SetProfilePage extends ConsumerStatefulWidget {
  final MyUser? initialUser;

  const SetProfilePage({super.key, this.initialUser});

  @override
  ConsumerState<SetProfilePage> createState() => _SetProfilePageState();
}

class _SetProfilePageState extends ConsumerState<SetProfilePage> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _userNameController = TextEditingController();
  late final MyUser _initialUser;


  @override
  void initState() {
    super.initState();
    _initialUser = widget.initialUser ?? MyUser.empty;
    _firstNameController.text = _initialUser.firstName ?? '';
    _lastNameController.text = _initialUser.lastName ?? '';
    _userNameController.text = _initialUser.username;
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _userNameController.dispose();
    super.dispose();
  }


  Future<void> _pickAvatarImage() async {
    try {
      final setProfileBloc = ref.read(setProfileBlocProvider(_initialUser));
      final mediaService = ref.read(mediaServiceProvider);

      // Show bottom sheet to choose camera/gallery
      final ImageSource? source = await showModalBottomSheet<ImageSource>(
        context: context,
        builder: (context) => SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Máy ảnh'),
                onTap: () => Navigator.pop(context, ImageSource.camera),
              ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Thư viện ảnh'),
                onTap: () => Navigator.pop(context, ImageSource.gallery),
              ),
              ListTile(
                leading: const Icon(Icons.cancel),
                title: const Text('Hủy'),
                onTap: () => Navigator.pop(context),
              ),
            ],
          ),
        ),
      );

      if (source != null) {
        final file = await mediaService.pickImage(
          source: source,
          maxWidth: 512,
          maxHeight: 512,
          imageQuality: 85,
        );

        if (file != null) {
          log("File path: ${file.path}");
          log("File size: ${await file.length()} bytes");
          log("File mime type: ${FileUtils.getMimeTypeFromExtension(file.path)}");
          final validationResult = FileUtils.validateAvatarFile(file);
          log("Validation result: isValid=${validationResult.isValid}, errorMessage=${validationResult.errorMessage}");
          log("errorMessage: ${validationResult.errorMessage}");
          if(!validationResult.isValid) {
            if(mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(validationResult.errorMessage!)),
              );
            }
            return;
          }

          final fileSize = await file.length();
          setProfileBloc.add(SetProfileAvatarUploadRequested(
            filePath: file.path,
            fileSize: fileSize,
          ));
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error picking image: $e')),
        );
      }
    }
  }

  void _onSaveProfile(SetProfileBloc setProfileBloc) {
    if (_formKey.currentState!.validate()) {
      setProfileBloc.add(const SetProfileSubmitted());
    }
  }

  @override
  Widget build(BuildContext context) {
    final setProfileBloc = ref.watch(setProfileBlocProvider(_initialUser));
    final l10n = AppLocalizations.of(context)!;
    return BlocProvider<SetProfileBloc>.value(
      value: setProfileBloc,
      child: BlocListener<SetProfileBloc, SetProfileState>(
        listenWhen: (previous, current) {
          return previous.errorMessage != current.errorMessage ||
              previous.isSuccess != current.isSuccess;
        },
        listener: (context, state) {
          if (state.isSuccess) {
            context.go('/home');
          } else if (state.errorMessage != null && state.errorMessage!.isNotEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Error: ${state.errorMessage!}')),
            );
          }
        },
        child: BlocBuilder<SetProfileBloc, SetProfileState>(
          builder: (context, state) {
            return Scaffold(
              body: SafeArea(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const SizedBox(height: 40),

                        Text(
                          l10n.profile_setup,
                          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),

                        const SizedBox(height: 32),

                        Center(
                          child: GestureDetector(
                            onTap: state.isAvatarUploading ? null : _pickAvatarImage,
                            child: Container(
                              width: 120,
                              height: 120,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.grey[200],
                                border: Border.all(
                                  color: Colors.grey[400]!,
                                  width: 2,
                                ),
                              ),
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  ClipOval(
                                    child: _buildAvatarContent(state),
                                  ),
                                  if (state.isAvatarUploading)
                                    Container(
                                      color: Colors.black.withOpacity(0.35),
                                      child: const Center(
                                        child: SizedBox(
                                          width: 28,
                                          height: 28,
                                          child: CircularProgressIndicator(strokeWidth: 3),
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 32),

                        InfoInput(
                          textController: _userNameController,
                          label: l10n.user_name_label,
                          onChanged: (value) {
                            setProfileBloc.add(SetProfileUserNameChanged(value));
                          },
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return l10n.fill_in_input_notify;
                            }
                            return null;
                          },
                        ),

                        const SizedBox(height: 16),

                        InfoInput(
                          textController: _firstNameController,
                          label: l10n.first_name_label,
                          onChanged: (value) {
                            setProfileBloc.add(SetProfileFirstNameChanged(value));
                          },
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return l10n.fill_in_input_notify;
                            }
                            return null;
                          },
                        ),

                        const SizedBox(height: 16),

                        InfoInput(
                          textController: _lastNameController,
                          label: l10n.last_name_label,
                          onChanged: (value) {
                            setProfileBloc.add(SetProfileLastNameChanged(value));
                          },
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return l10n.fill_in_input_notify;
                            }
                            return null;
                          },
                        ),

                        const SizedBox(height: 32),

                        ElevatedButton(
                          onPressed: state.canSubmit
                              ? () => _onSaveProfile(setProfileBloc)
                              : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blueAccent,
                            disabledBackgroundColor: Colors.blueAccent.withOpacity(0.45),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: state.isSubmitting
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2.5,
                                    color: Colors.white,
                                  ),
                                )
                              : Text(
                                  l10n.submit,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildAvatarContent(SetProfileState state) {
    if (state.avatarLocalPath != null && state.avatarLocalPath!.isNotEmpty) {
      return Image.file(
        File(state.avatarLocalPath!),
        fit: BoxFit.cover,
        width: 120,
        height: 120,
      );
    }

    if (_initialUser.avatarUrl != null && _initialUser.avatarUrl!.trim().isNotEmpty) {
      return Image.network(
        _initialUser.avatarUrl!,
        fit: BoxFit.cover,
        width: 120,
        height: 120,
      );
    }

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.camera_alt,
          size: 40,
          color: Colors.grey[600],
        ),
        const SizedBox(height: 8),
        Text(
          'Add photo',
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}