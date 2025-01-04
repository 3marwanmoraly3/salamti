import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:salamti/emergencyContacts/emergencyContacts.dart';
import 'package:formz/formz.dart';

class EmergencyContactsScreen extends StatefulWidget {
  const EmergencyContactsScreen({super.key});

  @override
  State<EmergencyContactsScreen> createState() => _EmergencyContactsState();
}

class _EmergencyContactsState extends State<EmergencyContactsScreen> {
  ValueNotifier formDismissedNotifier = ValueNotifier(false);
  TextEditingController nameController = TextEditingController();
  TextEditingController phoneController = TextEditingController();

  @override
  void dispose() {
    formDismissedNotifier.dispose();
    nameController.dispose();
    phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<EmergencyContactsBloc, EmergencyContactsState>(
      listener: (context, state) {
        if (state.formStatus.isFailure) {
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(
              SnackBar(
                  content:
                      Text(state.errorMessage ?? 'Failed to add contact.')),
            );
          context.read<EmergencyContactsBloc>().add(const ResetFormStatus());
        }
        if (state.status == UpdateContactStatus.success) {
          context.read<EmergencyContactsBloc>().add(const ResetFormStatus());
          Navigator.of(context).pop();
        }
      },
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(
            title: const Text(
              "Emergency Contacts",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 26),
            ),
            centerTitle: false,
            leading: IconButton(
              icon: const Icon(
                Icons.arrow_circle_left_rounded,
                size: 60,
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
              padding: EdgeInsets.zero,
            ),
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () {
              nameController.text = "";
              phoneController.text = "";
              showModalBottomSheet(
                context: context,
                builder: (_) {
                  return BlocProvider.value(
                    value: BlocProvider.of<EmergencyContactsBloc>(context),
                    child: Scaffold(
                      backgroundColor: Colors.transparent,
                      body: Padding(
                        padding:
                            const EdgeInsets.only(left: 20, top: 30, right: 20),
                        child: Align(
                          alignment: const Alignment(0, -1 / 3),
                          child: SingleChildScrollView(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Text(
                                  "Add Emergency Contact",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 8),
                                const Text(
                                  "Fill in your emergency contact details",
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 32),
                                _NameInput(controller: nameController),
                                const SizedBox(height: 2),
                                _PhoneInput(controller: phoneController),
                                const SizedBox(height: 4),
                                _AddContactButton(),
                                const SizedBox(height: 20),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ).then((_) {
                formDismissedNotifier.value = true;
              });
            },
            shape: const CircleBorder(),
            child: const Icon(
              Icons.add_rounded,
              size: 36,
            ),
          ),
          body: (state.status == UpdateContactStatus.loading)
              ? const Center(child: CircularProgressIndicator())
              : Column(
                  children: [
                    const SizedBox(height: 20),
                    _EmergencyContacts(
                      formDismissedNotifier: formDismissedNotifier,
                      nameController: nameController,
                      phoneController: phoneController,
                    ),
                    const SizedBox(height: 50),
                    ValueListenableBuilder(
                      valueListenable: formDismissedNotifier,
                      builder: (context, formDismissed, child) {
                        if (formDismissed) {
                          context
                              .read<EmergencyContactsBloc>()
                              .add(const FormDismissed());
                          formDismissedNotifier.value = false;
                        }
                        return Container();
                      },
                    ),
                  ],
                ),
        );
      },
    );
  }
}

class _NameInput extends StatelessWidget {
  final TextEditingController controller;

  _NameInput({required this.controller});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<EmergencyContactsBloc, EmergencyContactsState>(
      builder: (context, state) {
        return TextField(
          key: const Key('emergencyContactsForm_nameInput_textField'),
          controller: controller,
          onChanged: (name) =>
              context.read<EmergencyContactsBloc>().add(NameChanged(name)),
          onTapOutside: (_) => FocusManager.instance.primaryFocus?.unfocus(),
          keyboardType: TextInputType.name,
          style: const TextStyle(fontSize: 22),
          decoration: InputDecoration(
            hintText: 'Name',
            helperText: '',
            errorText: state.name.displayError != null ? 'Invalid name' : null,
            contentPadding:
                const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(50),
              borderSide: const BorderSide(color: Colors.black, width: 2),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(50),
              borderSide: const BorderSide(color: Colors.black, width: 2),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(50),
              borderSide: const BorderSide(color: Colors.black, width: 2),
            ),
          ),
        );
      },
    );
  }
}

class _PhoneInput extends StatelessWidget {
  final TextEditingController controller;

  const _PhoneInput({required this.controller});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<EmergencyContactsBloc, EmergencyContactsState>(
      buildWhen: (previous, current) => previous.phone != current.phone,
      builder: (context, state) {
        return TextField(
          key: const Key('emergencyContactsForm_phoneInput_textField'),
          controller: controller,
          onChanged: (phone) =>
              context.read<EmergencyContactsBloc>().add(PhoneChanged(phone)),
          onTapOutside: (_) => FocusManager.instance.primaryFocus?.unfocus(),
          keyboardType: TextInputType.phone,
          style: const TextStyle(fontSize: 22),
          decoration: InputDecoration(
            prefixIcon: const Padding(
                padding: EdgeInsets.only(left: 20, top: 15, bottom: 15),
                child: Text(
                  '+962 | ',
                  style: TextStyle(fontSize: 22),
                )),
            hintText: 'Phone Number',
            helperText: '',
            errorText: state.phone.displayError != null
                ? 'Invalid phone number'
                : null,
            contentPadding:
                const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(50),
              borderSide: const BorderSide(color: Colors.black, width: 2),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(50),
              borderSide: const BorderSide(color: Colors.black, width: 2),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(50),
              borderSide: const BorderSide(color: Colors.black, width: 2),
            ),
          ),
        );
      },
    );
  }
}

class _AddContactButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<EmergencyContactsBloc, EmergencyContactsState>(
      builder: (context, state) {
        return state.formStatus.isInProgress
            ? const CircularProgressIndicator()
            : ElevatedButton(
                key: const Key(
                    'emergencyContactsForm_addContactForm_raisedButton'),
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    fixedSize: const Size(170, 55)),
                onPressed: state.isValid
                    ? () => context
                        .read<EmergencyContactsBloc>()
                        .add(const EmergencyContactAddition())
                    : null,
                child: const Text(
                  'Confirm',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.w600),
                ),
              );
      },
    );
  }
}

class _EditContactButton extends StatelessWidget {
  final int index;

  const _EditContactButton({required this.index});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<EmergencyContactsBloc, EmergencyContactsState>(
      builder: (context, state) {
        return state.formStatus.isInProgress
            ? const SizedBox(
                width: 170,
                child: Column(
                  children: [
                    CircularProgressIndicator(),
                  ],
                ),
              )
            : ElevatedButton(
                key: const Key(
                    'emergencyContactsForm_editContactForm_raisedButton'),
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    fixedSize: const Size(170, 55)),
                onPressed: state.isValid
                    ? () => context
                        .read<EmergencyContactsBloc>()
                        .add(EmergencyContactEdit(index))
                    : null,
                child: const Text(
                  'Edit',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.w600),
                ),
              );
      },
    );
  }
}

class _RemoveContactButton extends StatelessWidget {
  final String name;
  final String phone;

  const _RemoveContactButton({required this.name, required this.phone});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<EmergencyContactsBloc, EmergencyContactsState>(
      builder: (context, state) {
        return state.status == UpdateContactStatus.remove
            ? const SizedBox(
                width: 170,
                child: Column(
                  children: [
                    CircularProgressIndicator(),
                  ],
                ),
              )
            : ElevatedButton(
                key: const Key(
                    'emergencyContactsForm_removeContactForm_raisedButton'),
                style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xfffd5f5f),
                    fixedSize: const Size(170, 55)),
                onPressed: () => context
                    .read<EmergencyContactsBloc>()
                    .add(EmergencyContactRemoval(name: name, phone: phone)),
                child: const Text(
                  'Delete',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.w600),
                ),
              );
      },
    );
  }
}

class _EmergencyContacts extends StatelessWidget {
  final ValueNotifier formDismissedNotifier;
  final TextEditingController nameController;
  final TextEditingController phoneController;

  const _EmergencyContacts(
      {required this.formDismissedNotifier,
      required this.nameController,
      required this.phoneController});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<EmergencyContactsBloc, EmergencyContactsState>(
      buildWhen: (previous, current) =>
          previous.emergencyContacts != current.emergencyContacts,
      builder: (context, state) {
        return Expanded(
          child: LayoutBuilder(
            builder: (context, BoxConstraints constraints) {
              return SizedBox(
                height: constraints.maxHeight,
                child: ListView.separated(
                    itemCount: state.emergencyContacts.length,
                    separatorBuilder: (context, index) =>
                        const Divider(thickness: 1),
                    itemBuilder: (context, index) {
                      final contact = state.emergencyContacts[index];
                      final String name = contact["name"];
                      final String phone = contact["phone"];
                      final shortPhone = phone.substring(1);
                      return ListTile(
                        title: Text(
                          name,
                          style: const TextStyle(
                              fontSize: 24, fontWeight: FontWeight.w500),
                        ),
                        subtitle: Text(
                          phone,
                          style: const TextStyle(fontSize: 20),
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.edit_rounded),
                          onPressed: () {
                            context
                                .read<EmergencyContactsBloc>()
                                .add(NameChanged(name));
                            context
                                .read<EmergencyContactsBloc>()
                                .add(PhoneChanged(shortPhone));
                            editContact(context, index, name, shortPhone);
                          },
                        ),
                      );
                    }),
              );
            },
          ),
        );
      },
    );
  }

  Future<void> editContact(
      BuildContext context, int index, String name, String phone) async {
    nameController.text = name;
    phoneController.text = phone;
    showModalBottomSheet(
      context: context,
      builder: (_) {
        return BlocProvider.value(
          value: BlocProvider.of<EmergencyContactsBloc>(context),
          child: Scaffold(
            backgroundColor: Colors.transparent,
            body: Padding(
              padding: const EdgeInsets.only(left: 20, top: 30, right: 20),
              child: Align(
                alignment: const Alignment(0, -1 / 3),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        "Edit Emergency Contact",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontSize: 22, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        "Edit your emergency contact details",
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 32),
                      _NameInput(controller: nameController),
                      const SizedBox(height: 2),
                      _PhoneInput(controller: phoneController),
                      const SizedBox(height: 4),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _RemoveContactButton(name: name, phone: phone),
                          _EditContactButton(index: index),
                        ],
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    ).then((_) {
      formDismissedNotifier.value = true;
    });
  }
}
