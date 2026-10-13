const express = require("express");
const cors = require("cors");
const dotenv = require("dotenv");
const nodemailer = require("nodemailer");
const crypto = require("crypto");

dotenv.config();

const app = express();

app.use(cors());
app.use(express.json());


// ============================================================
// TEMPORARY OTP STORAGE
// ============================================================

const otpStore = new Map();


// ============================================================
// GENERATE 6-DIGIT OTP
// ============================================================

function generateOTP() {
  return crypto
    .randomInt(100000, 1000000)
    .toString();
}


// ============================================================
// HASH OTP
// ============================================================

function hashOTP(otp) {
  return crypto
    .createHash("sha256")
    .update(otp)
    .digest("hex");
}


// ============================================================
// EMAIL CONFIGURATION
// ============================================================

const transporter = nodemailer.createTransport({
  service: "gmail",

  auth: {
    user: process.env.EMAIL_USER,
    pass: process.env.EMAIL_PASSWORD,
  },
});


// ============================================================
// TEST ROUTE
// ============================================================

app.get("/", (req, res) => {

  res.json({
    success: true,
    message: "StudentPerk Hub OTP Backend is running!",
  });

});


// ============================================================
// SEND OTP
// ============================================================

app.post("/send-otp", async (req, res) => {

  try {

    const { email } = req.body;

    // Check email
    if (!email) {

      return res.status(400).json({
        success: false,
        message: "Email is required.",
      });

    }

    const normalizedEmail =
      email.trim().toLowerCase();


    // Generate OTP
    const otp = generateOTP();


    // Hash OTP
    const otpHash = hashOTP(otp);


    // Expiry = 5 minutes
    const expiresAt =
      Date.now() + 5 * 60 * 1000;


    // Store OTP
    otpStore.set(normalizedEmail, {

      otpHash: otpHash,

      expiresAt: expiresAt,

      attempts: 0,

    });


    // Send email
    await transporter.sendMail({

      from: `"StudentPerk Hub" <${process.env.EMAIL_USER}>`,

      to: normalizedEmail,

      subject:
        "StudentPerk Hub - Email Verification OTP",

      html: `

        <div style="
          font-family: Arial, sans-serif;
          max-width: 600px;
          margin: auto;
          padding: 30px;
          border: 1px solid #eeeeee;
          border-radius: 12px;
        ">

          <h2 style="
            color: #6C63FF;
          ">
            StudentPerk Hub
          </h2>

          <p>
            Hello!
          </p>

          <p>
            Use the verification code below
            to verify your email address.
          </p>

          <div style="
            background: #f4f2ff;
            padding: 20px;
            text-align: center;
            border-radius: 10px;
            margin: 25px 0;
          ">

            <div style="
              font-size: 32px;
              font-weight: bold;
              letter-spacing: 8px;
              color: #4B3F9E;
            ">
              ${otp}
            </div>

          </div>

          <p>
            This OTP will expire in
            <strong>5 minutes</strong>.
          </p>

          <p>
            Do not share this OTP with anyone.
          </p>

          <hr>

          <p style="
            color: #777;
            font-size: 12px;
          ">
            StudentPerk Hub
          </p>

        </div>

      `,
    });


    return res.json({

      success: true,

      message: "OTP sent successfully.",

    });


  } catch (error) {

    console.error(
      "SEND OTP ERROR:",
      error
    );

    return res.status(500).json({

      success: false,

      message:
        "Failed to send OTP.",

    });

  }

});


// ============================================================
// VERIFY OTP
// ============================================================

app.post("/verify-otp", (req, res) => {

  try {

    const {
      email,
      otp,
    } = req.body;


    // Check fields
    if (!email || !otp) {

      return res.status(400).json({

        success: false,

        message:
          "Email and OTP are required.",

      });

    }


    const normalizedEmail =
      email.trim().toLowerCase();


    // Find OTP
    const storedOTP =
      otpStore.get(normalizedEmail);


    if (!storedOTP) {

      return res.status(404).json({

        success: false,

        message:
          "OTP not found. Please request a new OTP.",

      });

    }


    // Check expiry
    if (
      Date.now() >
      storedOTP.expiresAt
    ) {

      otpStore.delete(
        normalizedEmail
      );

      return res.status(400).json({

        success: false,

        message:
          "OTP has expired. Please request a new OTP.",

      });

    }


    // Check attempts
    if (
      storedOTP.attempts >= 5
    ) {

      otpStore.delete(
        normalizedEmail
      );

      return res.status(429).json({

        success: false,

        message:
          "Too many incorrect attempts. Please request a new OTP.",

      });

    }


    // Hash entered OTP
    const enteredHash =
      hashOTP(otp);


    // Compare
    if (
      enteredHash !==
      storedOTP.otpHash
    ) {

      storedOTP.attempts++;

      return res.status(400).json({

        success: false,

        message:
          "Incorrect OTP.",

      });

    }


    // OTP correct
    otpStore.delete(
      normalizedEmail
    );


    return res.json({

      success: true,

      message:
        "Email verified successfully.",

    });


  } catch (error) {

    console.error(
      "VERIFY OTP ERROR:",
      error
    );

    return res.status(500).json({

      success: false,

      message:
        "Failed to verify OTP.",

    });

  }

});


// ============================================================
// START SERVER
// ============================================================

const PORT =
  process.env.PORT || 3000;

app.listen(PORT, () => {

  console.log(
    `StudentPerk Hub backend running on port ${PORT}`
  );

});