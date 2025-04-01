const {onRequest} = require("firebase-functions/v2/https");
const logger = require("firebase-functions/logger");
const crypto = require("crypto");
const admin = require("firebase-admin");

admin.initializeApp();

// Replace with your Razorpay Webhook Secret
const WEBHOOK_SECRET = "Febin@123";

exports.razorpayWebhook = onRequest(async (req, res) => {
  if (req.method !== "POST") {
    logger.warn("Method not allowed", req.method);
    return res.status(405).send("Method Not Allowed");
  }

  const receivedSignature = req.headers["x-razorpay-signature"];
  if (!receivedSignature) {
    logger.error("Missing Razorpay signature header");
    return res.status(400).send("Missing signature header");
  }

  // Convert the request body to a string for signature verification
  const payload = JSON.stringify(req.body);
  const expectedSignature = crypto
      .createHmac("sha256", WEBHOOK_SECRET)
      .update(payload)
      .digest("hex");

  // Compare the signatures
  if (receivedSignature !== expectedSignature) {
    logger.error("Invalid signature", {
      receivedSignature: receivedSignature,
      expectedSignature: expectedSignature,
    });
    return res.status(400).send("Invalid signature");
  }

  const event = req.body.event;
  logger.info("Verified webhook event:", event);

  if (event === "payment.captured") {
    // Extract payment details
    const paymentDetails =
      req.body.payload &&
      req.body.payload.payment &&
      req.body.payload.payment.entity;

    logger.info("Payment captured details:", paymentDetails);

    // Retrieve the phone number the user entered on the Razorpay checkout page
    const phone =
      paymentDetails && paymentDetails.contact;// e.g. "7356514113"

    if (phone) {
      try {
        // Find the most recent docwithphoneNumber==phoneANDstatus=="Pending"
        // ordered by createdAt DESC
        const snapshot = await admin
            .firestore()
            .collection("Hospital_Appointments")
            .where("phoneNumber", "==", phone)
            .where("status", "==", "Pending")
            .orderBy("createdAt", "desc")
            .limit(1)
            .get();

        if (snapshot.empty) {
          logger.warn(`No pending booking found for phone: ${phone}`);
          return res.status(200).send("No matching pending booking");
        }

        // Update the first (most recent) matching doc: set status to "Paid"
        const doc = snapshot.docs[0];
        await doc.ref.update({
          status: "Paid",
          paymentDetails: paymentDetails,
        });

        logger.info(`Booking ${doc.id} updatedsuccessfullyfor phone: ${phone}`);
        return res.status(200).send("Webhook processed and booking updated");
      } catch (error) {
        logger.error("Error updating booking:", error);
        return res.status(500).send("Error updating booking");
      }
    } else {
      // If no phone is found in payment details,wecannot match it to a booking
      return res.status(200).send("Payment captured without phone number");
    }
  } else {
    // For events that are not explicitly handled
    return res.status(200).send("Event not handled");
  }
});
