import 'dart:async';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
// For PDF generation
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
// We'll navigate to TicketPreviewPage
import 'ticket_preview.dart';  // <-- Import the second file
import 'smsservice.dart';

class BookingAppointment extends StatefulWidget {
  final String hospitalId;
  final String hospitalName;
  final List<String> departments;

  const BookingAppointment({
    Key? key,
    required this.hospitalId,
    required this.hospitalName,
    required this.departments,
  }) : super(key: key);

  @override
  State<BookingAppointment> createState() => _BookingAppointmentState();
}

class _BookingAppointmentState extends State<BookingAppointment> {
  final _formKey = GlobalKey<FormState>();

  // Text Controllers
  final TextEditingController _nameController    = TextEditingController();
  final TextEditingController _phoneController   = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _reasonController  = TextEditingController();
  final TextEditingController _dateController    = TextEditingController();

  // Department & Doctor selection
  String? _selectedDepartment;
  List<Map<String, dynamic>> _doctorsList = [];
  String? _selectedDoctorId;

  // Availability
  Map<DateTime, bool> _availability = {};
  DateTime? _selectedDate;

  StreamSubscription<DocumentSnapshot>? _availabilitySubscription;

  @override
  void dispose() {
    _availabilitySubscription?.cancel();
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _reasonController.dispose();
    _dateController.dispose();
    super.dispose();
  }

  // ================== Department Dropdown ==================
  Widget _buildDepartmentDropdown() {
    return DropdownButtonFormField<String>(
      decoration: const InputDecoration(
        labelText: "Select Department",
        border: OutlineInputBorder(),
      ),
      value: _selectedDepartment,
      items: widget.departments.map((dept) {
        return DropdownMenuItem<String>(
          value: dept,
          child: Text(dept),
        );
      }).toList(),
      onChanged: (value) {
        setState(() {
          _selectedDepartment = value;
          _selectedDoctorId   = null;
          _doctorsList.clear();
          _selectedDate       = null;
          _dateController.clear();
        });
        _fetchDoctors();
      },
      validator: (value) =>
          value == null ? "Please select a department" : null,
    );
  }

  // ================== Doctor Dropdown ==================
  Widget _buildDoctorDropdown() {
    return DropdownButtonFormField<String>(
      decoration: const InputDecoration(
        labelText: "Select Doctor",
        border: OutlineInputBorder(),
      ),
      value: _selectedDoctorId,
      items: _doctorsList.map((doctor) {
        return DropdownMenuItem<String>(
          value: doctor['id'],
          child: Text(doctor['name']),
        );
      }).toList(),
      onChanged: (value) {
        setState(() {
          _selectedDoctorId = value;
          _selectedDate     = null;
          _dateController.clear();
        });
        _subscribeToAvailability();
      },
      validator: (value) =>
          value == null ? "Please select a doctor" : null,
    );
  }

  // ================== Fetch Doctors ==================
  Future<void> _fetchDoctors() async {
    if (_selectedDepartment == null) return;

    try {
      final hospitalRef = FirebaseFirestore.instance
          .collection('Hospitals')
          .doc(widget.hospitalId);

      final querySnapshot = await FirebaseFirestore.instance
          .collection('Doctors')
          .where('Hospital', isEqualTo: hospitalRef)
          .where('Department', isEqualTo: _selectedDepartment)
          .get();

      setState(() {
        _doctorsList = querySnapshot.docs.map((doc) {
          final data = doc.data();
          final doctorName = data['Name'] ?? 'Unnamed Doctor';

          return {
            'id':   doc.id, // Firestore doc ID
            'name': doctorName,
          };
        }).toList();
      });
    } catch (error) {
      debugPrint("Error fetching doctors: $error");
    }
  }

  // ================== Subscribe to Availability ==================
  void _subscribeToAvailability() {
    if (_selectedDoctorId == null) return;

    _availabilitySubscription?.cancel();

    _availabilitySubscription = FirebaseFirestore.instance
        .collection('Doctors_LTA')
        .doc(_selectedDoctorId)
        .snapshots()
        .listen((docSnapshot) {
      if (!docSnapshot.exists) {
        setState(() => _availability.clear());
        return;
      }

      final data = docSnapshot.data();
      if (data == null) {
        setState(() => _availability.clear());
        return;
      }

      final Map<DateTime, bool> newAvailability = {};

      data.forEach((key, value) {
        if (value is Map<String, dynamic>) {
          final bool? isWorking  = value['value'];
          final int? bookedSlot  = value['booked_slot'];
          final int? maxSlot     = value['max_slot'];

          if (isWorking == null || bookedSlot == null || maxSlot == null) {
            return;
          }

          final bool isAvailable = (isWorking && bookedSlot < maxSlot);

          try {
            final dateParsed = DateTime.parse(key);
            final normalized = DateTime(
              dateParsed.year,
              dateParsed.month,
              dateParsed.day,
            );
            newAvailability[normalized] = isAvailable;
          } catch (e) {
            debugPrint("Skipping invalid date key '$key': $e");
          }
        }
      });

      setState(() => _availability = newAvailability);
    });
  }

  // ================== Date Picker (TableCalendar) ==================
  void _selectDate() {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: Container(
          padding: const EdgeInsets.all(16),
          child: TableCalendar(
            focusedDay: _selectedDate ?? DateTime.now(),
            firstDay: DateTime.now(),
            lastDay: DateTime(2101),
            selectedDayPredicate: (day) => isSameDay(day, _selectedDate),
            onDaySelected: (selectedDay, focusedDay) {
              final normalized = DateTime(
                selectedDay.year,
                selectedDay.month,
                selectedDay.day,
              );

              final bool? isAvailable = _availability[normalized];
              if (isAvailable != true) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Date not available, select another date"),
                  ),
                );
                return;
              }

              setState(() {
                _selectedDate = normalized;
                _dateController.text =
                    DateFormat('yyyy-MM-dd').format(_selectedDate!);
              });
              Navigator.pop(context);
            },
            calendarBuilders: CalendarBuilders(
              defaultBuilder: (context, date, _) {
                final normalized = DateTime(date.year, date.month, date.day);
                final bool? available = _availability[normalized];
                Color dayColor;
                if (available == true) {
                  dayColor = Colors.green;
                } else if (available == false) {
                  dayColor = Colors.red;
                } else {
                  dayColor = Colors.grey[300]!;
                }

                return Container(
                  margin: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: dayColor,
                  ),
                  child: Center(
                    child: Text(
                      '${date.day}',
                      style: const TextStyle(color: Colors.black),
                    ),
                  ),
                );
              },
            ),
            headerStyle: const HeaderStyle(
              formatButtonVisible: false,
              titleCentered: true,
              leftChevronIcon:  Icon(Icons.chevron_left, color: Colors.black),
              rightChevronIcon: Icon(Icons.chevron_right, color: Colors.black),
            ),
          ),
        ),
      ),
    );
  }

  // ================== Submit Appointment ==================
  void _submitAppointment() async {
    if (_formKey.currentState!.validate()) {
      if (_selectedDate == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Please select a date.")),
        );
        return;
      }

      // We'll need the doctor's name for the PDF slip
      final doctorName = _doctorsList
          .firstWhere((doc) => doc['id'] == _selectedDoctorId)['name'];

      try {
        final doctorRef = FirebaseFirestore.instance
            .collection('Doctors_LTA')
            .doc(_selectedDoctorId);

        final year  = _selectedDate!.year.toString().padLeft(4, '0');
        final month = _selectedDate!.month.toString().padLeft(2, '0');
        final day   = _selectedDate!.day.toString().padLeft(2, '0');
        final dateKey = "${year}-${month}-${day}T00:00:00";

        int? finalBookedSlot;

        await FirebaseFirestore.instance.runTransaction((transaction) async {
          final freshSnap = await transaction.get(doctorRef);
          if (!freshSnap.exists) {
            throw Exception("Doctor's availability doc not found.");
          }

          final docData = Map<String, dynamic>.from(freshSnap.data()!);

          if (!docData.containsKey(dateKey)) {
            throw Exception("Selected date is not available in doc.");
          }

          final dateMapRaw = docData[dateKey];
          if (dateMapRaw is! Map<String, dynamic>) {
            throw Exception("Date map is invalid.");
          }

          final dateMap = Map<String, dynamic>.from(dateMapRaw);

          final bool? isWorking = dateMap['value'];
          final int bookedSlot  = dateMap['booked_slot'] ?? 0;
          final int maxSlot     = dateMap['max_slot'] ?? 0;

          if (isWorking != true || bookedSlot >= maxSlot) {
            throw Exception("No slots available for this date.");
          }

          final updatedBooked = bookedSlot + 1;
          dateMap['booked_slot'] = updatedBooked;

          finalBookedSlot = updatedBooked; // token number

          docData[dateKey] = dateMap;
          transaction.update(doctorRef, docData);

          // Create an appointment doc
          final appointmentRef = FirebaseFirestore.instance
              .collection('Hospital_Appointments')
              .doc();

          transaction.set(appointmentRef, {
            'patientName':   _nameController.text,
            'phoneNumber':   _phoneController.text,
            'address':       _addressController.text,
            'hospitalId':    widget.hospitalId,
            'hospitalName':  widget.hospitalName,
            'department':    _selectedDepartment,
            'doctorId':      _selectedDoctorId,
            'date':          _dateController.text,
            'reason':        _reasonController.text,
            'createdAt':     FieldValue.serverTimestamp(),
          });
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Appointment booked successfully!")),
        );

        // --- SMS Service Addition Start ---
        // Prepare phone number with default country code +91
        String phoneNumber = _phoneController.text.trim();
        if (!phoneNumber.startsWith("+91")) {
          phoneNumber = "+91" + phoneNumber;
        }
        // Instantiate and send SMS confirmation
        SmsService smsService = SmsService();
        await smsService.sendAppointmentConfirmation(
          phoneNumber,
          "Dear ${_nameController.text}, your appointment with Dr. $doctorName at ${widget.hospitalName} is confirmed for ${_dateController.text}. Your token no is ${finalBookedSlot ?? 0}. For any queries, contact us. Thank you!"
        );
        // --- SMS Service Addition End ---

        // 1) Generate PDF bytes
        final pdfBytes = await _createPdfSlip(
          tokenNumber: finalBookedSlot ?? 0,
          patientName: _nameController.text,
          phoneNumber: _phoneController.text,
          address: _addressController.text,
          reason: _reasonController.text,
          doctorName: doctorName,
          hospitalName: widget.hospitalName,
          dateString: _dateController.text,
        );

        // 2) Navigate to a "Ticket Preview" style page
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => TicketPreviewPage(
              pdfBytes: pdfBytes,
              tokenNumber: finalBookedSlot ?? 0,
              patientName: _nameController.text,
              phoneNumber: _phoneController.text,
              address: _addressController.text,
              reason: _reasonController.text,
              doctorName: doctorName,
              hospitalName: widget.hospitalName,
              dateString: _dateController.text,
              department: _selectedDepartment ?? "Not Specified",
            ),
          ),
        );
      } catch (e) {
        debugPrint("Error saving appointment: $e");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: $e")),
        );
      }
    }
  }

  // ================== Create PDF Slip (just bytes) ==================
  Future<Uint8List> _createPdfSlip({
    required int tokenNumber,
    required String patientName,
    required String phoneNumber,
    required String address,
    required String reason,
    required String doctorName,
    required String hospitalName,
    required String dateString,
  }) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Center(
                child: pw.Text(
                  hospitalName,
                  style: pw.TextStyle(
                    fontSize: 16, 
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
              ),
              pw.Center(
                child: pw.Text(
                  "Appointment Slip - Generated from Web Portal",
                  style: pw.TextStyle(fontSize: 12),
                ),
              ),
              pw.SizedBox(height: 10),
              pw.Divider(),

              pw.Text("Token No: $tokenNumber", style: pw.TextStyle(fontSize: 14)),

              pw.SizedBox(height: 5),
              pw.Text("Patient Name: $patientName", style: pw.TextStyle(fontSize: 12)),
              pw.Text("Phone Number: $phoneNumber", style: pw.TextStyle(fontSize: 12)),
              pw.Text("Address: $address", style: pw.TextStyle(fontSize: 12)),
              if (reason.trim().isNotEmpty)
                pw.Text("Reason: $reason", style: pw.TextStyle(fontSize: 12)),

              pw.SizedBox(height: 5),
              pw.Text("Doctor: $doctorName", style: pw.TextStyle(fontSize: 12)),
              pw.Text("Appointment Date: $dateString", style: pw.TextStyle(fontSize: 12)),

              pw.SizedBox(height: 10),
              pw.Text(
                "Disclaimer: This is an online generated token slip. "
                "Appointment will be subjected to the availability of doctor.",
                style: pw.TextStyle(fontSize: 10, fontStyle: pw.FontStyle.italic),
              ),

              pw.SizedBox(height: 20),
              pw.Center(
                child: pw.BarcodeWidget(
                  data: hospitalName, // or some address
                  barcode: pw.Barcode.qrCode(),
                  width: 100,
                  height: 100,
                ),
              ),
              pw.SizedBox(height: 10),
              pw.Center(
                child: pw.Text("Scan for Hospital Address", style: pw.TextStyle(fontSize: 10)),
              ),
            ],
          );
        },
      ),
    );

    return pdf.save();
  }

  // ================== Helper: Build TextField ==================
  Widget _buildTextField(
    String label,
    TextEditingController controller, {
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
    bool readOnly = false,
    VoidCallback? onTap,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller:    controller,
        keyboardType:  keyboardType,
        maxLines:      maxLines,
        readOnly:      readOnly,
        onTap:         onTap,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
        validator: validator,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Book a Service at ${widget.hospitalName}"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                _buildTextField(
                  "Patient Name",
                  _nameController,
                  validator: (value) =>
                      (value == null || value.trim().isEmpty)
                          ? "Patient name is required"
                          : null,
                ),

                _buildTextField(
                  "Phone Number",
                  _phoneController,
                  keyboardType: TextInputType.phone,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Phone number is required";
                    }
                    if (!RegExp(r'^\d{10}$').hasMatch(value)) {
                      return "Enter a valid 10-digit phone number";
                    }
                    return null;
                  },
                ),

                _buildTextField(
                  "Address",
                  _addressController,
                  validator: (value) =>
                      (value == null || value.trim().isEmpty)
                          ? "Address is required"
                          : null,
                ),

                _buildDepartmentDropdown(),
                const SizedBox(height: 8),

                _buildDoctorDropdown(),
                const SizedBox(height: 8),

                _buildTextField(
                  "Select Date",
                  _dateController,
                  readOnly: true,
                  onTap: _selectDate,
                  validator: (value) =>
                      (value == null || value.trim().isEmpty)
                          ? "Please pick a date"
                          : null,
                ),

                _buildTextField(
                  "Reason for Visit (Optional)",
                  _reasonController,
                  maxLines: 3,
                  validator: (_) => null,
                ),
                const SizedBox(height: 16),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _submitAppointment,
                    child: const Text("Book Now"),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
