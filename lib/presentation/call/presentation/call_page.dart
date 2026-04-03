import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_chat/presentation/call/blocs/call_bloc.dart';
import 'package:flutter_chat/presentation/call/providers/call_bloc_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CallPage extends ConsumerWidget {
  const CallPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final TextEditingController deviceTokenController = TextEditingController();
    final callBloc = ref.watch(callBlocProvider);
    return BlocProvider<CallBloc>.value(
      value: callBloc,
      child: BlocListener<CallBloc, CallState>(
        listener: (context, state) {
          switch (state) {
            case CallInitial():
              break;
            case CallLoading():
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Starting call...')),
              );
              break;
            case CallSuccess():
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Call started successfully!')),
              );
              break;
            case CallFailure(message: final message):
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Failed to start call: $message')),
              );
              break;
          }
        },
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextField(
                controller: deviceTokenController,
                decoration: const InputDecoration(
                  labelText: 'Device Token',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                  onPressed: () {
                    final deviceToken = deviceTokenController.text.trim();
                    if (deviceToken.isNotEmpty) {
                      callBloc.add(CallStarted(deviceToken));
                      deviceTokenController.clear();
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Please enter a device token')),
                      );
                    }
                  },
                  child: const Text('Start Call')),
            ],
          ),
        ),
      ),
    );
  }
}