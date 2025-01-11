import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:salamti/medicalId/medicalId.dart';
import 'package:intl/intl.dart';
import 'package:formz/formz.dart';

class MedicalIdForm extends StatefulWidget {
  const MedicalIdForm({super.key});

  @override
  State<MedicalIdForm> createState() => _MedicalIdFormState();
}

class _MedicalIdFormState extends State<MedicalIdForm> {
  @override
  Widget build(BuildContext context) {
    return BlocConsumer<MedicalIdBloc, MedicalIdState>(
      listener: (context, state) {
        if (state.formStatus == FormzSubmissionStatus.success) {
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(
              const SnackBar(content: Text('Updated Successfully!')),
            );
          context.read<MedicalIdBloc>().add(const ResetFormStatus());
        }
        if (state.formStatus.isFailure) {
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(
              SnackBar(content: Text(state.errorMessage ?? 'Failed to update')),
            );
          context.read<MedicalIdBloc>().add(const ResetFormStatus());
        }
      },
      builder: (context, state) {
        return Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            title: const Text(
              "Medical ID",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 28),
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
          body: (state.loading)
              ? const Center(child: CircularProgressIndicator())
              : ListView(
                  shrinkWrap: true,
                  children: [
                    const SizedBox(height: 20),
                    const Padding(
                      padding: EdgeInsets.only(left: 20),
                      child: Text(
                        "Date of Birth",
                        style: TextStyle(
                            fontSize: 20,
                            color: Colors.black,
                            fontWeight: FontWeight.w500),
                      ),
                    ),
                    const SizedBox(height: 10),
                    _DOBInput(),
                    const SizedBox(height: 10),
                    const Padding(
                      padding: EdgeInsets.only(left: 20),
                      child: Text(
                        "Gender",
                        style: TextStyle(
                            fontSize: 20,
                            color: Colors.black,
                            fontWeight: FontWeight.w500),
                      ),
                    ),
                    const SizedBox(height: 10),
                    _GenderInput(),
                    const SizedBox(height: 10),
                    const Padding(
                      padding: EdgeInsets.only(left: 20),
                      child: Text(
                        "Blood Type",
                        style: TextStyle(
                            fontSize: 20,
                            color: Colors.black,
                            fontWeight: FontWeight.w500),
                      ),
                    ),
                    const SizedBox(height: 10),
                    _BloodTypeInput(),
                    const SizedBox(height: 20),
                    _ListInputField(
                      title: 'Conditions',
                      hintText: 'Add Condition',
                      items: state.conditions,
                      isValid: state.isConditionValid,
                      onChanged: (condition) => context
                          .read<MedicalIdBloc>()
                          .add(ConditionChanged(condition)),
                      onAdd: (condition) => context
                          .read<MedicalIdBloc>()
                          .add(AddCondition(condition)),
                      onRemove: (index) => context
                          .read<MedicalIdBloc>()
                          .add(RemoveCondition(index)),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      state.conditionInput.displayError != null
                          ? 'Letters and numbers only'
                          : '',
                      style: const TextStyle(fontSize: 14, color: Colors.red),
                    ),

                    _ListInputField(
                      title: 'Allergies',
                      hintText: 'Add Allergy',
                      items: state.allergies,
                      isValid: state.isAllergyValid,
                      onChanged: (allergy) => context
                          .read<MedicalIdBloc>()
                          .add(AllergyChanged(allergy)),
                      onAdd: (allergy) => context
                          .read<MedicalIdBloc>()
                          .add(AddAllergy(allergy)),
                      onRemove: (index) => context
                          .read<MedicalIdBloc>()
                          .add(RemoveAllergy(index)),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      state.allergyInput.displayError != null
                          ? 'Letters and numbers only'
                          : '',
                      style: const TextStyle(fontSize: 14, color: Colors.red),
                    ),
                    _ListInputField(
                      title: 'Medications',
                      hintText: 'Add Medication',
                      items: state.medications,
                      isValid: state.isMedicationValid,
                      onChanged: (medication) => context
                          .read<MedicalIdBloc>()
                          .add(MedicationChanged(medication)),
                      onAdd: (medication) => context
                          .read<MedicalIdBloc>()
                          .add(AddMedication(medication)),
                      onRemove: (index) => context
                          .read<MedicalIdBloc>()
                          .add(RemoveMedication(index)),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      state.medicationInput.displayError != null
                          ? 'Letters and numbers only'
                          : '',
                      style: const TextStyle(fontSize: 14, color: Colors.red),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
        );
      },
    );
  }
}

class _GenderInput extends StatelessWidget {
  final List<String> genders = ["Male", "Female"];

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MedicalIdBloc, MedicalIdState>(
      buildWhen: (previous, current) => previous.gender != current.gender,
      builder: (context, state) {
        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(50),
            border: Border.all(color: Colors.black, width: 2),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
          child: DropdownButtonHideUnderline(
            child: DropdownButton(
              value: state.gender.isEmpty ? null : state.gender,
              hint: const Text(
                "Select Gender",
                style: TextStyle(
                  fontSize: 20,
                  color: Colors.black,
                ),
              ),
              style: const TextStyle(
                fontSize: 20,
                color: Colors.black,
              ),
              isExpanded: true,
              icon: const Icon(
                Icons.keyboard_arrow_down_rounded,
                size: 30,
              ),
              items: genders.map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              onChanged: (gender) {
                if (gender != null) {
                  context.read<MedicalIdBloc>().add(GenderChanged(gender));
                }
              },
            ),
          ),
        );
      },
    );
  }
}

class _BloodTypeInput extends StatelessWidget {
  final List<String> bloodTypes = [
    "A+",
    "A-",
    "B+",
    "B-",
    "O+",
    "O-",
    "AB+",
    "AB-"
  ];

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MedicalIdBloc, MedicalIdState>(
      buildWhen: (previous, current) => previous.bloodType != current.bloodType,
      builder: (context, state) {
        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(50),
            border: Border.all(color: Colors.black, width: 2),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
          child: DropdownButtonHideUnderline(
            child: DropdownButton(
              value: state.bloodType.isEmpty ? null : state.bloodType,
              hint: const Text(
                "Select Blood Type",
                style: TextStyle(
                  fontSize: 20,
                  color: Colors.black,
                ),
              ),
              style: const TextStyle(
                fontSize: 20,
                color: Colors.black,
              ),
              isExpanded: true,
              icon: const Icon(
                Icons.keyboard_arrow_down_rounded,
                size: 30,
              ),
              items: bloodTypes.map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              onChanged: (bloodType) {
                if (bloodType != null) {
                  context
                      .read<MedicalIdBloc>()
                      .add(BloodTypeChanged(bloodType));
                }
              },
            ),
          ),
        );
      },
    );
  }
}

class _DOBInput extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MedicalIdBloc, MedicalIdState>(
      buildWhen: (previous, current) => previous.dob != current.dob,
      builder: (context, state) {
        return GestureDetector(
          onTap: () async {
            final DateTime? picked = await showDatePicker(
              context: context,
              initialDate: state.dob.isNotEmpty
                  ? DateFormat('dd/MM/yyyy').parse(state.dob)
                  : DateTime(2000),
              firstDate: DateTime(1900),
              lastDate: DateTime.now(),
              builder: (context, child) {
                return Theme(
                  data: Theme.of(context).copyWith(
                    colorScheme: const ColorScheme.light(
                      primary: Colors.black,
                      onPrimary: Colors.white,
                      surface: Colors.white,
                      onSurface: Colors.black,
                    ),
                    textButtonTheme: TextButtonThemeData(
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.black,
                      ),
                    ),
                  ),
                  child: child!,
                );
              },
            );
            if (picked != null) {
              try {
                final formattedDate = DateFormat('dd/MM/yyyy').format(picked);
                context.read<MedicalIdBloc>().add(DOBChanged(formattedDate));
              } catch (e) {
                print('Error formatting date: $e');
              }
            }
          },
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(50),
              border: Border.all(color: Colors.black, width: 2),
            ),
            padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  state.dob.isNotEmpty ? state.dob : 'DD/MM/YYYY',
                  style: const TextStyle(
                    fontSize: 20,
                    color: Colors.black,
                  ),
                ),
                const Icon(
                  Icons.calendar_today_rounded,
                  color: Colors.black,
                  size: 26,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _ListInputField extends StatefulWidget {
  final String title;
  final String hintText;
  final List<dynamic>? items;
  final bool isValid;
  final Function(String) onChanged;
  final Function(String) onAdd;
  final Function(int) onRemove;

  const _ListInputField({
    required this.title,
    required this.hintText,
    required this.items,
    required this.isValid,
    required this.onChanged,
    required this.onAdd,
    required this.onRemove,
  });

  @override
  State<_ListInputField> createState() => _ListInputFieldState();
}

class _ListInputFieldState extends State<_ListInputField> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 20),
          child: Text(
            widget.title,
            style: const TextStyle(
                fontSize: 20,
                color: Colors.black,
                fontWeight: FontWeight.w500),
          ),
        ),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.only(top: 15),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(25),
            border: Border.all(color: Colors.black, width: 2),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _itemsList(),
              _inputField(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _itemsList() {
    return SizedBox(
      height: 150,
      child: widget.items != null && widget.items!.isNotEmpty
          ? ListView.separated(
        itemCount: widget.items?.length ?? 0,
        separatorBuilder: (context, index) =>
        const Divider(thickness: 1, color: Colors.black26),
        itemBuilder: (context, index) {
          final String item = widget.items![index];
          return Padding(
            padding: const EdgeInsets.only(left: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  item,
                  style: const TextStyle(fontSize: 20),
                ),
                IconButton(
                  onPressed: () => widget.onRemove(index),
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  icon: const Icon(
                    Icons.delete,
                    size: 20,
                  ),
                )
              ],
            ),
          );
        },
      )
          : Center(child: Text("No ${widget.title} Added")),
    );
  }

  Widget _inputField() {
    return Container(
      decoration: const BoxDecoration(
        border: Border(
          top: BorderSide(color: Colors.black, width: 2),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _controller,
              onChanged: widget.onChanged,
              onTapOutside: (_) => FocusManager.instance.primaryFocus?.unfocus(),
              keyboardType: TextInputType.text,
              style: const TextStyle(fontSize: 20),
              decoration: InputDecoration(
                hintText: widget.hintText,
                helperText: '',
                contentPadding:
                const EdgeInsets.only(left: 20, top: 15, right: 20),
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: IconButton(
              icon: Icon(
                Icons.add_circle_rounded,
                size: 30,
                color: widget.isValid ? Colors.black : Colors.black12,
              ),
              onPressed: widget.isValid
                  ? () {
                widget.onAdd(_controller.text);
                _controller.clear();
              }
                  : null,
            ),
          )
        ],
      ),
    );
  }
}