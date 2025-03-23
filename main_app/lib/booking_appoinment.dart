import 'dart:async';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
// For PDF generation
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
// For Razorpay payments
import 'package:razorpay_flutter/razorpay_flutter.dart';

import 'ticket_preview.dart';  // <-- Import your second file
import 'smsservice.dart';
import 'NoInternetComponent/Utils/network_utils.dart';

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

  // Hospital Price
  double _hospitalPrice = 0.0;

  // Razorpay instance
  late Razorpay _razorpay;

  @override
  void initState() {
    super.initState();
    _fetchHospitalPrice(); // Fetch price as soon as this screen initializes

    // Initialize Razorpay and set up event handlers.
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
  }

  @override
  void dispose() {
    _availabilitySubscription?.cancel();
    _razorpay.clear();
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _reasonController.dispose();
    _dateController.dispose();
    super.dispose();
  }

  // -------------------- Razorpay Event Handlers --------------------
  void _handlePaymentSuccess(PaymentSuccessResponse response) {
    debugPrint("Payment Successful: ${response.paymentId}");
    _submitAppointment();
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    debugPrint("Payment Error: ${response.code} | ${response.message}");
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Payment failed: ${response.message}")),
    );
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    debugPrint("External Wallet: ${response.walletName}");
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("External wallet selected: ${response.walletName}")),
    );
  }
  // -------------------- End Razorpay Handlers --------------------

  // ================== 1) Fetch Hospital Price ==================
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

  // ================== 2) Department Dropdown ==================
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

  // ================== 3) Doctor Dropdown ==================
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

  // ================== 4) Fetch Doctors ==================
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

  // ================== 5) Subscribe to Availability ==================
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
          if (isWorking == null || bookedSlot == null || maxSlot == null) return;
          final bool isAvailable = (isWorking && bookedSlot < maxSlot);
          try {
            final dateParsed = DateTime.parse(key);
            final normalized = DateTime(dateParsed.year, dateParsed.month, dateParsed.day);
            newAvailability[normalized] = isAvailable;
          } catch (e) {
            debugPrint("Skipping invalid date key '$key': $e");
          }
        }
      });
      setState(() => _availability = newAvailability);
    });
  }

  // ================== 6) Date Picker (TableCalendar) ==================
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
              final normalized = DateTime(selectedDay.year, selectedDay.month, selectedDay.day);
              final bool? isAvailable = _availability[normalized];
              if (isAvailable != true) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Date not available, select another date")),
                );
                return;
              }
              setState(() {
                _selectedDate = normalized;
                _dateController.text = DateFormat('yyyy-MM-dd').format(_selectedDate!);
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
                  child: Center(child: Text('${date.day}', style: const TextStyle(color: Colors.black))),
                );
              },
            ),
            headerStyle: const HeaderStyle(
              formatButtonVisible: false,
              titleCentered: true,
              leftChevronIcon: Icon(Icons.chevron_left, color: Colors.black),
              rightChevronIcon: Icon(Icons.chevron_right, color: Colors.black),
            ),
          ),
        ),
      ),
    );
  }

  // ================== 7) Show Custom Payment Bottom Sheet ==================
  void _showCustomPaymentSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: false,
      backgroundColor: Colors.transparent,
      enableDrag: true,
      builder: (BuildContext context) {
        return Container(
          height: 300,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(16),
              topRight: Radius.circular(16),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 8),
              // Drag handle at top center
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
              // "quick pay" title and close icon
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: SizedBox(
                  height: 24,
                  child: Stack(
                    children: [
                      const Center(
                        child: Text(
                          "quick pay",
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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
              // Amount payable and hospital name display
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
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "amount payable",
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                        ),
                        Text(
                          "₹${_hospitalPrice.toStringAsFixed(2)}",
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "${widget.hospitalName} · booking",
                      style: const TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: const [
                        Expanded(child: Divider(color: Colors.grey, height: 1)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    // Display Google Pay icon (left unchanged for now)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset(
                          'assets/icons/gpay_icon.png',
                          width: 24,
                          height: 24,
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          "Google Pay ",
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const Spacer(),
              // PAY NOW button
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () async {
                      Navigator.pop(context); // Close the bottom sheet
                      await _payWithGPay();   // Initiate Razorpay payment flow
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
                                style: TextStyle(fontSize: 6, fontWeight: FontWeight.w300),
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
                  // Handle additional payment options if needed.
                },
                child: const Text(
                  "VIEW ALL PAYMENT OPTIONS",
                  style: TextStyle(fontSize: 14, color: Colors.blue),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  // ================== 8) Razorpay Payment Integration ==================
  Future<void> _payWithGPay() async {
    // Replace these placeholders with your actual Razorpay credentials/details:
    const String razorpayKey = "YOUR_RAZORPAY_KEY"; // Replace with your Razorpay Key
    // Amount in paise (multiply your rupees by 100)
    int amountInPaise = (_hospitalPrice * 100).toInt();

    var options = {
      'key': razorpayKey,
      'amount': amountInPaise, // Amount in paise
      'name': 'Hospital Payment', // Your merchant name
      'description': 'Booking Payment',
      'prefill': {
        'contact': _phoneController.text,
        'email': '', // Optionally add prefill email if available
      },
      'external': {
        'wallets': ['paytm']
      }
    };

    try {
      _razorpay.open(options);
      // The payment event handlers (_handlePaymentSuccess, etc.) will manage the result.
    } catch (e) {
      debugPrint("Razorpay Payment error: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Payment error: $e")),
      );
    }
  }

  // ================== 9) Submit Appointment to Firestore ==================
  Future<void> _submitAppointment() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select a date.")),
      );
      return;
    }

    final doctorName = _doctorsList
        .firstWhere((doc) => doc['id'] == _selectedDoctorId)['name'];

    try {
      final doctorRef = FirebaseFirestore.instance
          .collection('Doctors_LTA')
          .doc(_selectedDoctorId);
      final year  = _selectedDate!.year.toString().padLeft(4, '0');
      final month = _selectedDate!.month.toString().padLeft(2, '0');
      final day   = _selectedDate!.day.toString().padLeft(2, '0');
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
        final appointmentRef = FirebaseFirestore.instance
            .collection('Hospital_Appointments')
            .doc();
        transaction.set(appointmentRef, {
          'patientName': _nameController.text,
          'phoneNumber': _phoneController.text,
          'address': _addressController.text,
          'hospitalId': widget.hospitalId,
          'hospitalName': widget.hospitalName,
          'department': _selectedDepartment,
          'doctorId': _selectedDoctorId,
          'date': _dateController.text,
          'reason': _reasonController.text,
          'createdAt': FieldValue.serverTimestamp(),
        });
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Appointment booked successfully!")),
      );

      // --- SMS Service (optional) ---
      String phoneNumber = _phoneController.text.trim();
      if (!phoneNumber.startsWith("+91")) {
        phoneNumber = "+91" + phoneNumber;
      }
      SmsService smsService = SmsService();
      await smsService.sendAppointmentConfirmation(
        phoneNumber,
        "Dear ${_nameController.text}, your appointment with Dr. $doctorName at ${widget.hospitalName} is confirmed for ${_dateController.text}. Your token no is ${finalBookedSlot ?? 0}. For any queries, contact us. Thank you!"
      );
      // --- End of SMS Service ---

      // Generate PDF slip
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

      // Navigate to ticket preview page
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

  // ================== 10) Create PDF Slip ==================
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
                  style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold),
                ),
              ),
              pw.Center(
                child: pw.Text("Appointment Slip - Generated from Web Portal", style: pw.TextStyle(fontSize: 12)),
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
              pw.Text("Disclaimer: This is an online generated token slip. Appointment will be subjected to the availability of doctor.",
                  style: pw.TextStyle(fontSize: 10, fontStyle: pw.FontStyle.italic)),
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
              pw.Center(child: pw.Text("Scan for Hospital Address", style: pw.TextStyle(fontSize: 10))),
            ],
          );
        },
      ),
    );
    return pdf.save();
  }

  // ================== 11) Helper: Build TextField ==================
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

  // ================== 12) Build Method ==================
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
                // Book Now button triggers the custom bottom sheet
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                      onPressed: () {
                        NetworkUtils.checkAndProceed(context, () {
                          if (_formKey.currentState!.validate()) {
                            if (_selectedDate == null) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text("Please select a date.")),
                              );
                               return;
                          }
                          _showCustomPaymentSheet();
                          }
                      });
                      },
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
