const fetch = require("node-fetch"); // Ensure node-fetch@2 is installed
const {onRequest} = require("firebase-functions/v2/https");
const logger = require("firebase-functions/logger");
const {defineSecret} = require("firebase-functions/params");

// Define PayPal secrets
const PAYPAL_CLIENT_ID = defineSecret("PAYPAL_CLIENT_ID");
const PAYPAL_SECRET = defineSecret("PAYPAL_SECRET");

// Base URL for PayPal API (use live URL for production)
const PAYPAL_BASE = "https://api-m.sandbox.paypal.com";

/**
 * Generates an access token from PayPal using stored credentials.
 * @return {Promise<string>} The access token.
 */
async function generateAccessToken() {
  try {
    // Retrieve PayPal credentials from Firebase Secrets
    const clientId = PAYPAL_CLIENT_ID.value() || process.env.PAYPAL_CLIENT_ID;
    const secret = PAYPAL_SECRET.value() || process.env.PAYPAL_SECRET;

    if (!clientId || !secret) {
      throw new Error("Missing PayPal credentials");
    }

    // Log part of the clientId to verify loading
    // without exposing full credentials
    logger.info("PayPal credentials loaded:", {
      clientId: clientId.substring(0, 5) + "..."});

    const auth = Buffer.from(`${clientId}:${secret}`).toString("base64");

    const response = await fetch(`${PAYPAL_BASE}/v1/oauth2/token`, {
      method: "POST",
      headers: {
        "Authorization": `Basic ${auth}`,
        "Content-Type": "application/x-www-form-urlencoded",
      },
      body: "grant_type=client_credentials",
    });

    // Log the response status for debugging
    logger.info("Access token request response status:", response.status);

    const data = await response.json();
    // Log the complete response data for debugging
    logger.info("Access token response data:", data);

    if (!data.access_token) {
      throw new Error("Failed to retrieve access token");
    }

    return data.access_token;
  } catch (error) {
    logger.error("Error generating PayPal access token:", error);
    throw error;
  }
}

// Cloud Function: Create a PayPal order using the amount from the Flutter app.
exports.createOrder = onRequest(
    {secrets: [PAYPAL_CLIENT_ID, PAYPAL_SECRET]},
    async (req, res) => {
      try {
      // Read the amount from the request body (passed from your app)
        const {amount} = req.body;
        if (!amount) {
          res.status(400).send("Amount is required");
          return;
        }

        // Generate an access token from PayPal.
        const accessToken = await generateAccessToken();

        // Build the order payload using the passed amount.
        const orderPayload = {
          intent: "CAPTURE",
          purchase_units: [
            {
              amount: {
                currency_code: "INR",
                value: amount,
              },
            },
          ],
          application_context: {
            brand_name: "Digikalady",
            landing_page: "BILLING",
            user_action: "PAY_NOW",
            return_url: "myapp://bookingAppointment?status=success",
            cancel_url: "myapp://bookingAppointmentCancel",
          },
        };

        // Log the order payload before sending the request
        logger.info("Order Payload:", orderPayload);

        // Create the order via PayPal's Orders API.
        const orderResponse = await fetch(`${PAYPAL_BASE}/v2/checkout/orders`, {
          method: "POST",
          headers: {
            "Content-Type": "application/json",
            "Authorization": `Bearer ${accessToken}`,
          },
          body: JSON.stringify(orderPayload),
        });

        // Log the order creation response status
        logger.info("Order creation response status:", orderResponse.status);

        const orderData = await orderResponse.json();
        // Log the complete response data for debugging
        logger.info("Order creation response data:", orderData);

        if (!orderData || !orderData.links) {
          throw new Error("Invalid response from PayPal");
        }

        // Extract the approval URL from the response (link with rel:"approve")
        const approvalLink =
      orderData.links.find((link) => link.rel === "approve");
        const approvalUrl = approvalLink ? approvalLink.href : null;

        if (!approvalUrl) {
          throw new Error("Approval URL not found");
        }

        // Return the approval URL and order ID to your Flutter app.
        res.json({approval_url: approvalUrl, order_id: orderData.id});
      } catch (error) {
        logger.error("Error creating PayPal order:", error);
        res.status(500).send("Error creating order");
      }
    },
);
