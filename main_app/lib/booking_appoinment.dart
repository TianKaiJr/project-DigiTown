import 'dart:async';
import 'dart:typed_data';
import 'dart:ui'; // For ImageFilter (blur)
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
// For PDF generation
import 'package:pdf/widgets.dart' as pw;
// We'll navigate to TicketPreviewPage
import 'ticket_preview.dart';  // <-- Import the second file
import 'smsservice.dart';
// ================== ADDED: URL Launcher for Razorpay Link ==================
import 'package:url_launcher/url_launcher.dart';
// ================== ADDED: Lottie for Animation ==================
import 'package:lottie/lottie.dart';

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
  String? _selectedDoctorName; // NEW: Store selected doctor's name

  // Availability
  Map<DateTime, bool> _availability = {};
  DateTime? _selectedDate;

  StreamSubscription<DocumentSnapshot>? _availabilitySubscription;

  // ================== ADDED: Hospital Price Variable ==================
  double _hospitalPrice = 0.0;

  // ================== ADDED: For Listening to Status Changes ==================
  StreamSubscription<DocumentSnapshot>? _statusSubscription;

  // ================== ADDED: Payment Timeout Timer ==================
  Timer? _paymentTimer;

  // ================== ADDED: For Payment Animation Control ==================
  // Notifier to signal when payment is successful
  final ValueNotifier<bool> _paymentSuccessNotifier = ValueNotifier(false);
  // Booking id stored to finalize appointment later
  String? _currentBookingId;

  @override
  void initState() {
    super.initState();
    _fetchHospitalPrice(); // Fetch price as soon as this screen initializes
  }

  @override
  void dispose() {
    _availabilitySubscription?.cancel();
    _statusSubscription?.cancel();
    _paymentTimer?.cancel();
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _reasonController.dispose();
    _dateController.dispose();
    _paymentSuccessNotifier.dispose();
    super.dispose();
  }

  // ================== ADDED: Fetch Hospital Price ==================
  Future<void> _fetchHospitalPrice() async {
    try {
      final docSnapshot = await FirebaseFirestore.instance
          .collection('AMOUNT')
          .doc('Hospital')
          .get();

      if (docSnapshot.exists) {
        final data = docSnapshot.data() as Map<String, dynamic>;
        final dynamic priceValue = data[widget.hospitalId];
        if (priceValue != null) {
          setState(() {
            _hospitalPrice = double.tryParse(priceValue.toString()) ?? 0.0;
          });
        }
      }
    } catch (e) {
      debugPrint("Error fetching hospital price: $e");
    }
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
          _selectedDoctorName = null; // Reset doctor name on department change
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
        // Set both _selectedDoctorId and _selectedDoctorName dynamically
        setState(() {
          _selectedDoctorId = value;
          _selectedDate     = null;
          _dateController.clear();
          // Find the doctor name from _doctorsList using the selected id
          final selectedDoctor = _doctorsList.firstWhere(
            (doc) => doc['id'] == value,
            orElse: () => {'name': 'Selected Doctor'},
          );
          _selectedDoctorName = selectedDoctor['name'];
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
            'id':   doc.id,
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

  // ================== Show Custom Payment Bottom Sheet ==================
  void _showCustomPaymentSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: false,
      backgroundColor: Colors.transparent,
      enableDrag: true,
      builder: (BuildContext context) {
        return Container(
          height: 300, // Same height as before
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(16),
              topRight: Radius.circular(16),
            ),
          ),
          // Wrap the Column in SingleChildScrollView
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 8),
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: SizedBox(
                    height: 24,
                    child: Stack(
                      children: [
                        Center(
                          child: Text(
                            "quick pay",
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Positioned(
                          right: 0,
                          child: GestureDetector(
                            onTap: () => Navigator.pop(context),
                            child: const Icon(Icons.close),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Row: "amount payable" (left) and the fetched price (right)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            "amount payable",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            "₹${_hospitalPrice.toStringAsFixed(2)}",
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "${widget.hospitalName} · booking",
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: const [
                          Expanded(
                            child: Divider(color: Colors.grey, height: 1),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.payment, size: 24),
                          const SizedBox(width: 8),
                          const Text(
                            "Razorpay Payment Link",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                // Replace Spacer() with a fixed SizedBox
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () async {
                        Navigator.pop(context); // Close the bottom sheet
                        await _payWithRazorpay(); // Initiate Razorpay link flow with animation
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        child: RichText(
                          text: TextSpan(
                            style: const TextStyle(fontSize: 16, color: Colors.white),
                            children: [
                              TextSpan(text: "₹${_hospitalPrice.toStringAsFixed(2)} "),
                              WidgetSpan(
                                alignment: PlaceholderAlignment.middle,
                                child: Text(
                                  "●",
                                  style: const TextStyle(
                                    fontSize: 6,
                                    fontWeight: FontWeight.w300,
                                  ),
                                ),
                              ),
                              const TextSpan(text: " PAY NOW"),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    // If you want to show more payment options, handle here.
                  },
                  child: const Text(
                    "VIEW ALL PAYMENT OPTIONS",
                    style: TextStyle(fontSize: 14, color: Colors.blue),
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        );
      },
    );
  }

  // ================== PART A: Create a Pending Doc ==================
  Future<String> _createPendingBooking() async {
    final appointmentRef = FirebaseFirestore.instance
        .collection('Hospital_Appointments')
        .doc();

    // Convert phone to +91
    String rawPhone = _phoneController.text.trim();
    if (!rawPhone.startsWith("+91")) {
      rawPhone = "+91" + rawPhone;
    }

    await appointmentRef.set({
      'patientName': _nameController.text,
      'phoneNumber': rawPhone,
      'address': _addressController.text,
      'hospitalId': widget.hospitalId,
      'hospitalName': widget.hospitalName,
      'department': _selectedDepartment,
      'doctorId': _selectedDoctorId,
      'date': _dateController.text,
      'reason': _reasonController.text,
      'createdAt': FieldValue.serverTimestamp(),
      // "Pending" means user hasn't paid yet
      'status': 'Pending',
    });

    return appointmentRef.id;
  }

  // ================== PART B: Listen for Status == "Paid" ==================
  void _listenForStatusChanges(String docId) {
    _statusSubscription?.cancel();
    _statusSubscription = FirebaseFirestore.instance
        .collection('Hospital_Appointments')
        .doc(docId)
        .snapshots()
        .listen((docSnapshot) {
      if (!docSnapshot.exists) return;
      final data = docSnapshot.data();
      if (data == null) return;

      final status = data['status'];
      if (status == 'Paid') {
        // Payment confirmed by webhook, cancel the timeout timer
        _paymentTimer?.cancel();
        _paymentTimer = null;

        _statusSubscription?.cancel();
        _statusSubscription = null;
        // Signal the payment animation to complete.
        _paymentSuccessNotifier.value = true;
      }
    });
    // ADDED: Start a 2-minute timeout to check if payment is completed.
    _startPaymentTimeout(docId);
  }

  // ================== ADDED: Start Payment Timeout ==================
  void _startPaymentTimeout(String docId) {
    _paymentTimer?.cancel();
    _paymentTimer = Timer(Duration(minutes: 2), () async {
      // After 2 minutes, check the doc's status.
      final docSnapshot = await FirebaseFirestore.instance
          .collection('Hospital_Appointments')
          .doc(docId)
          .get();
      if (docSnapshot.exists) {
        final data = docSnapshot.data();
        if (data != null && data['status'] == 'Pending') {
          // Payment is still pending. Inform the user.
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Payment incomplete, try again.")),
          );
          // Optionally, cancel the listener.
          _statusSubscription?.cancel();
          _statusSubscription = null;
        }
      }
    });
  }

  // ================== PART C: Finalize Appointment Once Paid ==================
  Future<void> _finalizeAppointment(String docId) async {
    try {
      // 1. Get the doc
      final bookingDoc = await FirebaseFirestore.instance
          .collection('Hospital_Appointments')
          .doc(docId)
          .get();

      if (!bookingDoc.exists) {
        throw Exception("Booking not found");
      }

      final data = bookingDoc.data()!;
      final phoneNumber = data['phoneNumber'] ?? "";
      final doctorId    = data['doctorId'] as String?;
      final dateString  = data['date'] as String?;

      if (doctorId == null || dateString == null) {
        throw Exception("Missing doctorId or dateString");
      }

      final doctorRef = FirebaseFirestore.instance
          .collection('Doctors_LTA')
          .doc(doctorId);

      // 2. Increment the doctor's slot
      final parsedDate = DateTime.parse(dateString);
      final year  = parsedDate.year.toString().padLeft(4, '0');
      final month = parsedDate.month.toString().padLeft(2, '0');
      final day   = parsedDate.day.toString().padLeft(2, '0');
      final dateKey = "$year-$month-${day}T00:00:00";

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
        finalBookedSlot = updatedBooked;

        docData[dateKey] = dateMap;
        transaction.update(doctorRef, docData);
      });

      // 3. Send SMS with updated text and dynamic doctor name
      String phone = phoneNumber;
      if (!phone.startsWith("+91")) {
        phone = "+91" + phone;
      }
      SmsService smsService = SmsService();
      await smsService.sendAppointmentConfirmation(
        phone,
        "Dear ${_nameController.text}, your appointment with Dr. ${_selectedDoctorName ?? 'Selected Doctor'} at ${widget.hospitalName} is confirmed for ${_dateController.text}. Your token no is ${finalBookedSlot ?? 0}. For any queries, contact us. Thank you!"
      );

      // 4. Generate PDF slip
      final pdfBytes = await _createPdfSlip(
        tokenNumber: finalBookedSlot ?? 0,
        patientName: data['patientName'] ?? "",
        phoneNumber: phoneNumber,
        address: data['address'] ?? "",
        reason: data['reason'] ?? "",
        doctorName: _selectedDoctorName ?? 'Selected Doctor',
        hospitalName: data['hospitalName'] ?? "",
        dateString: dateString,
      );

      // 5. Show slip
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => TicketPreviewPage(
            pdfBytes: pdfBytes,
            tokenNumber: finalBookedSlot ?? 0,
            patientName: data['patientName'] ?? "",
            phoneNumber: phoneNumber,
            address: data['address'] ?? "",
            reason: data['reason'] ?? "",
            doctorName: _selectedDoctorName ?? 'Selected Doctor',
            hospitalName: data['hospitalName'] ?? "",
            dateString: dateString,
            department: data['department'] ?? "Not Specified",
          ),
        ),
      );
    } catch (e) {
      debugPrint("Error finalizing appointment: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error finalizing: $e")),
      );
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
                  data: hospitalName,
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

  // ================== "Book Now" => Validate & Show Payment Options ==================
  void _onBookNowPressed() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select a date.")),
      );
      return;
    }

    // Only show the payment options. Doc creation happens when "PAY NOW" is clicked.
    _showCustomPaymentSheet();
  }

  // ================== ADDED: _payWithRazorpay Method with Payment Animation & Cancel ==================
  Future<void> _payWithRazorpay() async {
    try {
      // Create the pending booking doc and start listening for status changes when "PAY NOW" is clicked.
      final bookingId = await _createPendingBooking();
      _currentBookingId = bookingId;
      _listenForStatusChanges(bookingId);

      // 1. Show Payment Animation Dialog with cancel option.
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          return PaymentAnimationDialog(
            paymentSuccessNotifier: _paymentSuccessNotifier,
            onAnimationComplete: () {
              Navigator.pop(context); // Close the animation dialog
              // After animation completes, finalize appointment.
              if (_currentBookingId != null) {
                _finalizeAppointment(_currentBookingId!);
              }
            },
            onCancel: () async {
              // Delete the newly created doc from Firebase.
              if (_currentBookingId != null) {
                await FirebaseFirestore.instance
                    .collection('Hospital_Appointments')
                    .doc(_currentBookingId)
                    .delete();
                _currentBookingId = null;
              }
              Navigator.pop(context); // Close the animation dialog
            },
          );
        },
      );

      // 2. Launch Razorpay Payment Link externally.
      final url = "https://razorpay.me/@digikalady?amount=tEDHZxxCtz0rKFL9kTzhOw%3D%3D";
      if (await canLaunchUrl(Uri.parse(url))) {
        await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
      } else {
        throw "Could not launch $url";
      }
    } catch (e) {
      debugPrint("Payment error: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Payment failed: $e")),
      );
    }
  }

  // ================== Build TextField Helper ==================
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
        controller: controller,
        keyboardType: keyboardType,
        maxLines: maxLines,
        readOnly: readOnly,
        onTap: onTap,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
        validator: validator,
      ),
    );
  }

  // ================== UI ==================
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
                    onPressed: _onBookNowPressed,
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

// ================== Payment Animation Dialog Widget ==================
class PaymentAnimationDialog extends StatefulWidget {
  final ValueNotifier<bool> paymentSuccessNotifier;
  final VoidCallback onAnimationComplete;
  final Future<void> Function()? onCancel;

  const PaymentAnimationDialog({
    Key? key,
    required this.paymentSuccessNotifier,
    required this.onAnimationComplete,
    this.onCancel,
  }) : super(key: key);

  @override
  _PaymentAnimationDialogState createState() => _PaymentAnimationDialogState();
}

class _PaymentAnimationDialogState extends State<PaymentAnimationDialog>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  bool _isLooping = true;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this);

    // Listen to payment success notifier.
    widget.paymentSuccessNotifier.addListener(() {
      if (widget.paymentSuccessNotifier.value && _isLooping) {
        _isLooping = false;
        _controller.stop();
        _controller.animateTo(1.0).then((_) {
          widget.onAnimationComplete();
        });
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Blurred background with 50% readability.
        BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
          child: Container(color: Colors.black.withOpacity(0)),
        ),
        Dialog(
          backgroundColor: Colors.transparent,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Lottie.asset(
                'assets/lottie/loading_tick.json',
                controller: _controller,
                onLoaded: (composition) {
                  _controller.duration = composition.duration;
                  _controller.repeat(min: 0.1, max: 0.3);
                },
              ),
              const SizedBox(height: 30), // Extra space to bring the cancel button further down
              GestureDetector(
                onTap: () async {
                  if (widget.onCancel != null) {
                    await widget.onCancel!();
                  }
                },
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.close, color: Colors.black, size: 24),
                ),
              ),
              const SizedBox(height: 10), // Additional bottom spacing
            ],
          ),
        ),
      ],
    );
  }
}
