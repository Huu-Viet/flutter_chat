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
  const SetProfilePage({super.key});

  @override
  ConsumerState<SetProfilePage> createState() => _SetProfilePageState();
}

class _SetProfilePageState extends ConsumerState<SetProfilePage> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _userNameController = TextEditingController();
  File? _avatarImage;

  MyUser currentUser = MyUser.empty;
  // bool _isLoading = false; later use for loading state


  @override
  void initState() {
    super.initState();
    ref.read(setProfileBlocProvider).add(SetProfileGetPreviousInfo());
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    super.dispose();
  }


  Future<void> _pickAvatarImage() async {
    try {
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
          setState(() {
            _avatarImage = file;
          });
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
      MyUser updatedUser = currentUser.copyWith(
        firstName: _firstNameController.text.trim(),
        lastName: _lastNameController.text.trim(),
        username: _userNameController.text.trim(),
      );
      setProfileBloc.add(SetProfileSubmitted(myUser: updatedUser));
    }
  }

  @override
  Widget build(BuildContext context) {
    final setProfileBloc = ref.read(setProfileBlocProvider);
    final l10n = AppLocalizations.of(context)!;
    return BlocProvider<SetProfileBloc>.value(
      value: setProfileBloc,
      child: BlocListener<SetProfileBloc, SetProfileState>(
        listener: (context, state) {
          if (state is SetProfilePreviousInfoLoaded){
            currentUser = state.myUser;
          } else if (state is SetProfileSuccess) {
            context.go('/home');
          } else if (state is SetProfileFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Error: ${state.errorMessage}')),
            );
          }
        },
        child: Scaffold(
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

                    // Avatar picker
                    Center(
                      child: GestureDetector(
                        onTap: _pickAvatarImage,
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
                          child: _avatarImage != null
                              ? ClipOval(
                            child: Image.file(
                              _avatarImage!,
                              fit: BoxFit.cover,
                              width: 120,
                              height: 120,
                            ),
                          )
                              : Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.camera_alt,
                                size: 40,
                                color: Colors.grey[600],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Thêm ảnh',
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 12,
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
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return l10n.fill_in_input_notify;
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 32),

                    ElevatedButton(
                      onPressed: () => _onSaveProfile(setProfileBloc),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blueAccent,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        l10n.submit,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}