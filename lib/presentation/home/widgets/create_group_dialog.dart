import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_chat/features/auth/auth_providers.dart';
import 'package:flutter_chat/features/auth/export.dart';
import 'package:flutter_chat/features/upload_media/upload_media_providers.dart';
import 'package:flutter_chat/presentation/home/blocs/home_bloc.dart';
import 'package:flutter_chat/presentation/home/home_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

class CreateGroupDialog extends ConsumerStatefulWidget {
	const CreateGroupDialog({super.key});

	@override
	ConsumerState<CreateGroupDialog> createState() => _CreateGroupDialogState();
}

class _CreateGroupDialogState extends ConsumerState<CreateGroupDialog> {
	final TextEditingController _nameController = TextEditingController();
	final TextEditingController _descriptionController = TextEditingController();
	final TextEditingController _searchController = TextEditingController();
	final ImagePicker _picker = ImagePicker();

	File? _selectedImage;
	String? _mediaId;
	String? _errorMessage;
	String? _currentUserId;
	bool _isUploadingImage = false;
	bool _isSearchingUsers = false;
	bool _isSubmitting = false;
	bool _hasSearched = false;

	List<MyUser> _searchResults = const <MyUser>[];
	final Map<String, MyUser> _selectedUsersById = <String, MyUser>{};

	@override
	void initState() {
		super.initState();
		_loadCurrentUserId();
	}

	Future<void> _loadCurrentUserId() async {
		final result = await ref.read(getCurrentUserIdUseCaseProvider)();

		if (!mounted) {
			return;
		}

		result.fold(
			(_) => null,
			(userId) {
				setState(() {
					_currentUserId = userId.trim();
				});
			},
		);
	}

	@override
	void dispose() {
		_nameController.dispose();
		_descriptionController.dispose();
		_searchController.dispose();
		super.dispose();
	}

	Future<void> _pickAndUploadImage() async {
		final image = await _picker.pickImage(
			source: ImageSource.gallery,
			imageQuality: 85,
			maxWidth: 1024,
			maxHeight: 1024,
		);

		if (image == null) {
			return;
		}

		final file = File(image.path);
		final fileSize = await file.length();

		setState(() {
			_selectedImage = file;
			_mediaId = null;
			_errorMessage = null;
			_isUploadingImage = true;
		});

		final result = await ref.read(uploadMediaUseCaseProvider)(
					file.path,
					'image',
					fileSize,
					null,
				);

		if (!mounted) {
			return;
		}

		result.fold(
			(failure) {
				setState(() {
					_isUploadingImage = false;
					_errorMessage = failure.message;
				});
			},
			(mediaInfo) {
				final uploadedMediaId = mediaInfo.mediaId?.trim();
				if (uploadedMediaId == null || uploadedMediaId.isEmpty) {
					setState(() {
						_isUploadingImage = false;
						_errorMessage = 'Upload image failed: missing mediaId';
					});
					return;
				}

				setState(() {
					_isUploadingImage = false;
					_mediaId = uploadedMediaId;
					_errorMessage = null;
				});
			},
		);
	}

	Future<void> _searchUsers() async {
		final query = _searchController.text.trim();
		if (query.isEmpty) {
			setState(() {
				_hasSearched = true;
				_searchResults = const <MyUser>[];
				_errorMessage = null;
			});
			return;
		}

		setState(() {
			_isSearchingUsers = true;
			_hasSearched = true;
			_errorMessage = null;
		});

		final result = await ref.read(searchUsersByUsernameUseCaseProvider)(
					query,
					page: 1,
					limit: 20,
				);

		if (!mounted) {
			return;
		}

		result.fold(
			(failure) {
				setState(() {
					_isSearchingUsers = false;
					_errorMessage = failure.message;
					_searchResults = const <MyUser>[];
				});
			},
			(users) {
				final currentUserId = _currentUserId;
				final filtered = users
					.where((user) => currentUserId == null || user.id.trim() != currentUserId)
					.toList(growable: false);

				setState(() {
					_isSearchingUsers = false;
					_searchResults = filtered;
				});
			},
		);
	}

	void _toggleUserSelection(MyUser user) {
		setState(() {
			if (_selectedUsersById.containsKey(user.id)) {
				_selectedUsersById.remove(user.id);
			} else {
				_selectedUsersById[user.id] = user;
			}
			_errorMessage = null;
		});
	}

	Future<void> _submit() async {
		final groupName = _nameController.text.trim();
		final description = _descriptionController.text.trim();
		final memberIds = _selectedUsersById.keys
				.map((id) => id.trim())
				.where((id) => id.isNotEmpty)
				.toSet()
				.toList(growable: false);

		if (groupName.isEmpty) {
			setState(() {
				_errorMessage = 'Group name is required';
			});
			return;
		}

		if (memberIds.length < 2) {
			setState(() {
				_errorMessage = 'Please select at least 2 users';
			});
			return;
		}

		if (_isUploadingImage) {
			setState(() {
				_errorMessage = 'Image is uploading, please wait';
			});
			return;
		}

		setState(() {
			_isSubmitting = true;
			_errorMessage = null;
		});

		ref.read(homeBlocProvider).add(
					CreateGroupEvent(
						name: groupName,
						description: description,
						memberIds: memberIds,
						mediaId: _mediaId,
					),
				);

		if (!mounted) {
			return;
		}
		Navigator.of(context).pop();
	}

	@override
	Widget build(BuildContext context) {
		return AlertDialog(
			title: const Text('Create Group'),
			content: SingleChildScrollView(
				child: Column(
					mainAxisSize: MainAxisSize.min,
					crossAxisAlignment: CrossAxisAlignment.start,
					children: [
						Center(
							child: GestureDetector(
								onTap: (_isUploadingImage || _isSubmitting)
										? null
										: _pickAndUploadImage,
								child: CircleAvatar(
									radius: 38,
									backgroundImage:
											_selectedImage != null ? FileImage(_selectedImage!) : null,
									child: _selectedImage == null
											? (_isUploadingImage
													? const SizedBox(
															height: 20,
															width: 20,
															child: CircularProgressIndicator(strokeWidth: 2),
														)
													: const Icon(Icons.camera_alt_outlined))
											: null,
								),
							),
						),
						const SizedBox(height: 8),
						Center(
							child: Text(
								_mediaId != null
										? 'Image uploaded'
										: 'Tap avatar to pick group image',
								style: Theme.of(context).textTheme.bodySmall,
							),
						),
						const SizedBox(height: 16),
						TextField(
							controller: _nameController,
							enabled: !_isSubmitting,
							textInputAction: TextInputAction.next,
							decoration: const InputDecoration(
								labelText: 'Group name',
								border: OutlineInputBorder(),
							),
						),
						const SizedBox(height: 12),
						TextField(
							controller: _descriptionController,
							enabled: !_isSubmitting,
							textInputAction: TextInputAction.next,
							minLines: 2,
							maxLines: 3,
							decoration: const InputDecoration(
								labelText: 'Description',
								border: OutlineInputBorder(),
							),
						),
						const SizedBox(height: 12),
						TextField(
							controller: _searchController,
							enabled: !_isSubmitting,
							textInputAction: TextInputAction.search,
							onSubmitted: (_) => _searchUsers(),
							decoration: InputDecoration(
								labelText: 'Search users by username',
								hintText: 'Enter username',
								prefixIcon: const Icon(Icons.search),
								suffixIcon: IconButton(
									onPressed: (_isSubmitting || _isSearchingUsers)
										? null
										: _searchUsers,
									icon: _isSearchingUsers
										? const SizedBox(
											height: 16,
											width: 16,
											child: CircularProgressIndicator(strokeWidth: 2),
										)
										: const Icon(Icons.arrow_forward),
								),
								border: const OutlineInputBorder(),
							),
						),
						const SizedBox(height: 12),
						if (_selectedUsersById.isNotEmpty) ...[
							Text(
								'Selected users (${_selectedUsersById.length})',
								style: Theme.of(context).textTheme.bodyMedium,
							),
							const SizedBox(height: 8),
							Wrap(
								spacing: 8,
								runSpacing: 8,
								children: _selectedUsersById.values.map((user) {
									final display = user.displayName.trim().isNotEmpty
											? user.displayName
											: user.username;
									return Chip(
										label: Text(display),
										onDeleted: _isSubmitting
											? null
											: () => _toggleUserSelection(user),
									);
								}).toList(growable: false),
							),
							const SizedBox(height: 12),
						],
						if (_isSearchingUsers)
							const Padding(
								padding: EdgeInsets.symmetric(vertical: 8),
								child: Center(child: CircularProgressIndicator()),
							)
						else if (_hasSearched)
							Builder(
								builder: (context) {
									if (_searchResults.isEmpty) {
										return Container(
											width: double.infinity,
											padding: const EdgeInsets.all(12),
											decoration: BoxDecoration(
												border: Border.all(color: Theme.of(context).dividerColor),
												borderRadius: BorderRadius.circular(10),
											),
											child: const Text('No users found'),
										);
									}

									final user = _searchResults.first;
									final selected = _selectedUsersById.containsKey(user.id);
									final display = user.displayName.trim().isNotEmpty
											? user.displayName
											: user.username;

									return Container(
										width: double.infinity,
										padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
										decoration: BoxDecoration(
											border: Border.all(color: Theme.of(context).dividerColor),
											borderRadius: BorderRadius.circular(10),
										),
										child: Row(
											children: [
												Expanded(
													child: Column(
														crossAxisAlignment: CrossAxisAlignment.start,
														children: [
															Text(
																display,
																maxLines: 1,
																overflow: TextOverflow.ellipsis,
															),
															Text(
																user.id,
																maxLines: 1,
																overflow: TextOverflow.ellipsis,
																style: Theme.of(context).textTheme.bodySmall,
															),
														],
													),
												),
												const SizedBox(width: 8),
												FilledButton.tonal(
													onPressed: _isSubmitting
														? null
														: () => _toggleUserSelection(user),
													child: Text(selected ? 'Added' : 'Add'),
												),
											],
										),
									);
								},
							),
						const SizedBox(height: 12),
						if (_errorMessage != null) ...[
							const SizedBox(height: 12),
							Text(
								_errorMessage!,
								style: TextStyle(
									color: Theme.of(context).colorScheme.error,
								),
							),
						],
					],
				),
			),
			actions: [
				TextButton(
					onPressed: _isSubmitting ? null : () => Navigator.of(context).pop(),
					child: const Text('Cancel'),
				),
				FilledButton(
					onPressed: (_isSubmitting || _isUploadingImage) ? null : _submit,
					child: _isSubmitting
							? const SizedBox(
									height: 18,
									width: 18,
									child: CircularProgressIndicator(strokeWidth: 2),
								)
							: const Text('Create'),
				),
			],
		);
	}
}
